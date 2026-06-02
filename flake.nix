{
  description = "Nix configuration for Oddware systems";

  nixConfig = {
    extra-substituters = [
      "https://nixos-raspberrypi.cachix.org"
      "https://cache.lix.systems"
      "https://cache.nixos.org/"
    ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
      "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
    connect-timeout = 5;
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
      # inputs.brew-src.url = "github:Homebrew/brew/master";
    };
    # Optional: Declarative tap management
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    nixos-raspberrypi = {
      url = "github:nvmd/nixos-raspberrypi/main";
    };

    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";
    };
  };

  outputs =
    inputs@{
      self,
      darwin,
      nixpkgs,
      home-manager,
      nix-homebrew,
      homebrew-core,
      homebrew-cask,
      nixos-raspberrypi,
      nixos-anywhere,
      ...
    }:
    let
      configuration =
        { pkgs, ... }:
        {
          # Most stuff that was hare, has now been split to separate files.

          # This would overwrite /etc/shells, so leaving this commented for now
          # environment.shells = [ pkgs.zsh ];

          # Tip from @ofalvai:matrix.org in the Nix on macOS channel, at 2025-03-09, to make the linux-builder service not start automatically:
          # launchd.daemons.linux-builder = {
          #   serviceConfig = {
          #     KeepAlive = lib.mkForce false;
          #     RunAtLoad = lib.mkForce false;
          #   };
          # };

          # Enable alternative shell support in nix-darwin.
          # programs.fish.enable = true;
          # Create /etc/zshrc that loads the nix-darwin environment.
          programs.zsh = {
            enable = true;
          };

        };
      allSystems = nixpkgs.lib.systems.flakeExposed;
      forSystems = systems: f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {

      devShells = forSystems allSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            nativeBuildInputs = with pkgs; [
              nil # lsp language server for nix
              nixpkgs-fmt
              nix-output-monitor
              nixos-anywhere.packages.${system}.default
            ];
          };
        }
      );

      # installerImages = nixos-raspberrypi.installerImages.rpi4;

      nixosConfigurations =
        let
          users-config-stub =
            { config, pkgs, ... }:
            {
              # This is identical to what nixos installer does in
              # (modulesPash + "profiles/installation-device.nix")

              users.users = {
                nixos = {
                  isNormalUser = true;
                  extraGroups = [
                    "wheel"
                    "networkmanager"
                    "video"
                  ];
                  # Allow the graphical user to login without password
                  initialHashedPassword = "";
                  openssh.authorizedKeys.keys = [
                    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP+8RJi9manjKv4+ybqYq1zniojiXf21R7fUvGdXCO9P odd-mbp-m1"
                  ];
                };
                root = {
                  # Allow the user to log in as root without a password.
                  initialHashedPassword = "";
                  openssh.authorizedKeys.keys = [
                    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP+8RJi9manjKv4+ybqYq1zniojiXf21R7fUvGdXCO9P odd-mbp-m1"
                  ];
                };
                oddee = {
                  isNormalUser = true;
                  extraGroups = [
                    "wheel"
                    "networkmanager"
                    "video"
                  ];
                  # Allow the graphical user to login without password
                  initialHashedPassword = "";
                  openssh.authorizedKeys.keys = [
                    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP+8RJi9manjKv4+ybqYq1zniojiXf21R7fUvGdXCO9P odd-mbp-m1"
                  ];
                  shell = pkgs.zsh;
                };
              };

              # Don't require sudo/root to `reboot` or `poweroff`.
              security.polkit.enable = true;

              # Allow passwordless sudo from nixos user
              security.sudo = {
                enable = true;
                wheelNeedsPassword = false;
              };

              # Automatically log in at the virtual consoles.
              services.getty.autologinUser = "nixos";

              # We run sshd by default. Login is only possible after adding a
              # password via "passwd" or by adding a ssh key to ~/.ssh/authorized_keys.
              # The latter one is particular useful if keys are manually added to
              # installation device for head-less systems i.e. arm boards by manually
              # mounting the storage in a different system.
              services.openssh = {
                enable = true;
                openFirewall = true;
                settings = {
                  PermitRootLogin = "prohibit-password";
                  PasswordAuthentication = false;
                  KbdInteractiveAuthentication = false;
                };
              };

              # allow nix-copy to live system
              nix.settings = {
                auto-optimise-store = true;
                trusted-users = [
                  "oddee"
                  "@wheel"
                ];
              };
              nix.gc = {
                automatic = true;
                dates = "weekly";
                options = "--delete-older-than 14d";
              };

              # Make swedish kb work by default
              console.keyMap = "sv-latin1";

              # We are stateless, so just default to latest.
              system.stateVersion = config.system.nixos.release;
            };

          network-config = {
            # This is mostly portions of safe network configuration defaults that
            # nixos-images and srvos provide

            networking = {
              useNetworkd = true;
              firewall.allowedUDPPorts = [ 5353 ]; # mDNS
              wireless = {
                enable = false;
                # Use iwd instead of wpa_supplicant. It has a user friendly CLI
                iwd = {
                  enable = false;
                  settings = {
                    Network = {
                      EnableIPv6 = true;
                      RoutePriorityOffset = 300;
                    };
                    Settings.AutoConnect = true;
                  };
                };
              };
            };

            systemd = {
              network.networks = {
                "99-ethernet-default-dhcp".networkConfig.MulticastDNS = "yes";
                "99-wireless-client-dhcp".networkConfig.MulticastDNS = "yes";
              };
              # This comment was lifted from `srvos`
              # Do not take down the network for too long when upgrading,
              # This also prevents failures of services that are restarted instead of stopped.
              # It will use `systemctl restart` rather than stopping it with `systemctl stop`
              # followed by a delayed `systemctl start`.
              services = {
                systemd-networkd.stopIfChanged = false;
                # Services that are only restarted might be not able to resolve when resolved is stopped before
                systemd-resolved.stopIfChanged = false;
              };
            };

          };

          common-user-config =
            { config, pkgs, ... }:
            {
              imports = [
                users-config-stub
                network-config
              ];

              time.timeZone = "Europe/Stockholm";
              networking.hostName = "rpi4";

              services.udev.extraRules = ''
                # Ignore partitions with "Required Partition" GPT partition attribute
                # On our RPis this is firmware (/boot/firmware) partition
                ENV{ID_PART_ENTRY_SCHEME}=="gpt", \
                  ENV{ID_PART_ENTRY_FLAGS}=="0x1", \
                  ENV{UDISKS_IGNORE}="1"
              '';

              environment = {
                shells = [ pkgs.zsh ];
                systemPackages = with pkgs; [
                  tree
                  htop
                ];
              };

              system.nixos.tags =
                let
                  cfg = config.boot.loader.raspberry-pi;
                in
                [
                  "raspberry-pi-${cfg.variant}"
                  cfg.bootloader
                  config.boot.kernelPackages.kernel.version
                ];
            };

        in
        {
          # TODO: find out if we need nixosSystemFull, or if nixosSystem will suffice
          # Or even nixosInstaller?
          rpi4 = nixos-raspberrypi.lib.nixosInstaller {
            specialArgs = inputs;
            modules = [
              (
                {
                  config,
                  pkgs,
                  lib,
                  nixos-raspberrypi,
                  ...
                }:
                {
                  imports = with nixos-raspberrypi.nixosModules; [
                    # Hardware configuration
                    raspberry-pi-4.base
                    raspberry-pi-4.display-vc4
                    raspberry-pi-4.bluetooth
                    # It seems none of the options in this file works, need to find out why
                    # ./pi4-configtxt.nix
                  ];
                }
              )
              (
                { config, pkgs, ... }:
                {
                  fileSystems = {
                    "/boot/firmware" = {
                      device = "/dev/disk/by-label/FIRMWARE";
                      fsType = "vfat";
                      options = [
                        "noatime"
                        "noauto"
                        "x-systemd.automount"
                        "x-systemd.idle-timeout=1min"
                      ];
                    };
                    "/" = {
                      device = "/dev/disk/by-label/NIXOS_SD";
                      fsType = "ext4";
                      options = [ "noatime" ];
                    };
                  };
                }
              )
              # Further user configuration
              common-user-config
              {
                boot.tmp.useTmpfs = true;
              }

              # Advanced: Use non-default kernel from kernel-firmware bundle
              (
                {
                  config,
                  pkgs,
                  lib,
                  ...
                }:
                let
                  kernelBundle = pkgs.linuxAndFirmware.v6_12_87;
                in
                {
                  boot = {
                    loader.raspberry-pi.firmwarePackage = kernelBundle.raspberrypifw;
                    kernelPackages = kernelBundle.linuxPackages_rpi4;
                    kernelParams = [
                      "cgroup_enable=cpuset"
                      "cgroup_enable=memory"
                      "cgroup_memory=1"
                    ];
                  };

                  nixpkgs.overlays = lib.mkAfter [
                    (self: super: {
                      # This is used in (modulesPath + "/hardware/all-firmware.nix") when at least
                      # enableRedistributableFirmware is enabled
                      # I know no easier way to override this package
                      inherit (kernelBundle) raspberrypiWirelessFirmware;
                      # Some derivations want to use it as an input,
                      # e.g. raspberrypi-dtbs, omxplayer, sd-image-* modules
                      inherit (kernelBundle) raspberrypifw;
                    })
                  ];

                  nix.settings.experimental-features = [
                    "nix-command"
                    "flakes"
                  ];

                  environment.systemPackages = with pkgs; [
                    curl
                    file
                    git
                    htop
                    lsof
                    openssl
                    psmisc
                    tmux
                    vim
                    wget
                    zsh
                  ];

                }
              )

            ];
          };
        };

      # Build with: nix build --max-jobs 0 .#images.rpi4
      # --max-jobs 0 makes it happen on the linux-builder instead of locally.
      images.rpi4 = self.nixosConfigurations.rpi4.config.system.build.sdImage;

      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#$hostname
      darwinConfigurations = {
        "odd-mbp-m1" = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            ./nix-cfg.nix
            ./hosts/odd-mbp-m1/systempackages.nix
            ./hosts/odd-mbp-m1/homebrew.nix
            ./hosts/odd-mbp-m1/security.nix
            ./hosts/odd-mbp-m1/nixpkgs.nix
            (import ./hosts/odd-mbp-m1/system.nix { inherit self; })
            configuration
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                enable = true;
                enableRosetta = true;
                user = "oddee";
                autoMigrate = true;
              };
            }
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                backupFileExtension = "bak";
                useGlobalPkgs = false;
                useUserPackages = true;
                users.oddee = import ./hosts/odd-mbp-m1/home.nix;
              };
              users.users.oddee.home = "/Users/oddee";
            }
          ];
          specialArgs = { inherit inputs; };
        };

        # "odd-mbp" = darwin.lib.darwinSystem {
        #   system = "x86_64-darwin";
        #   modules = [
        #     ./nix-cfg.nix
        #     ./hosts/odd-mbp/systempackages.nix
        #     ./hosts/odd-mbp/homebrew.nix
        #     ./hosts/odd-mbp/security.nix
        #     ./hosts/odd-mbp/nixpkgs.nix
        #     (import ./hosts/odd-mbp/system.nix { inherit self; })
        #     configuration
        #     nix-homebrew.darwinModules.nix-homebrew
        #     {
        #       nix-homebrew = {
        #         enable = true;
        #         enableRosetta = false;
        #         user = "oddee";
        #         autoMigrate = true;
        #       };
        #     }
        #     home-manager.darwinModules.home-manager
        #     {
        #       home-manager = {
        #         useGlobalPkgs = false;
        #         useUserPackages = true;
        #         users.oddee = import ./hosts/odd-mbp/home.nix;
        #       };
        #       users.users.oddee.home = "/Users/oddee";
        #     }
        #   ];
        #   specialArgs = { inherit inputs; };
        # };
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."odd-mbp-m1".pkgs;
    };
}
