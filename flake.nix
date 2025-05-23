{
  description = "Nix configuration for Oddware systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.93.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Not in use yet, might need to be under home-manager config instead?
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, darwin, nixpkgs, home-manager, nixvim, lix-module }:
    let
      configuration = { pkgs, ... }: {
        # List packages installed in system profile. To search by name, run:
        # $ nix-env -qaP | grep wget
        # Think I want to just have the bare minimum shell tools here, and solve 
        # the rest with home-manager.
        environment.systemPackages = with pkgs; [
          btop
          coreutils-full
          devenv
          ghostscript
          git
          imagemagick
          mc
          nodejs_23 # Common for a lot of nvim stuff, so might just always have it
          rclone
          tree-sitter
          vim
          zsh
        ];

        # This would overwrite /etc/shells, so leaving this commented for now
        # environment.shells = [ pkgs.zsh ];

        # I'd like to not use homebrew, but nice to have a fallback if there are packages 
        # not available in nix
        homebrew = {
          enable = true;
          global = {
            autoUpdate = true;
          };
          onActivation = {
            autoUpdate = true;
            cleanup = "uninstall";
            upgrade = true;
          };
          brews = [
            # "libolm" # needed for developing with mautrix-go, remove when done
          ];
          casks = [
            # {
            #   name = "aerospace";
            #   greedy = true;
            # }
            # {
            #   name = "adobe-digital-editions";
            #   greedy = true;
            # }
            {
              name = "android-studio";
              greedy = true;
            }
            {
              name = "beeper";
              greedy = true;
            }
            {
              name = "brave-browser";
              greedy = true;
            }
            {
              name = "calibre";
              greedy = true;
            }
            # {
            #   name = "chirp";
            #   greedy = true;
            # }
            {
              name = "element";
              greedy = true;
            }
            {
              name = "font-hack-nerd-font";
              greedy = true;
            }
            {
              name = "font-jetbrains-mono";
              greedy = true;
            }
            {
              name = "font-inconsolata";
              greedy = true;
            }
            {
              name = "google-chrome";
              greedy = true;
            }
            {
              name = "google-drive";
              greedy = true;
            }
            {
              name = "ilok-license-manager";
              greedy = true;
            }
            {
              name = "jump-desktop-connect";
              greedy = true;
            }
            {
              name = "keepassxc";
              greedy = true;
            }
            {
              name = "nheko";
              greedy = true;
            }
            {
              name = "orbstack";
              greedy = true;
            }
            {
              name = "rancher";
              greedy = true;
            }
            {
              name = "resilio-sync";
              greedy = true;
            }
            {
              name = "scroll-reverser";
              greedy = true;
            }
            {
              name = "signal";
              greedy = true;
            }
            {
              name = "tailscale";
              greedy = true;
            }
            {
              name = "tidal";
              greedy = true;
            }
            {
              name = "tuta-mail";
              greedy = true;
            }
            {
              name = "utm";
              greedy = true;
            }
            {
              name = "visual-studio-code";
              greedy = true;
            }
            {
              name = "vlc";
              greedy = true;
            }
            {
              name = "warp";
              greedy = true;
            }
            {
              name = "wezterm";
              greedy = true;
            }
          ];
        };

        # Tip from @ofalvai:matrix.org in the Nix on macOS channel, at 2025-03-09, to make the linux-builder service not start automatically:
        # launchd.daemons.linux-builder = {
        #   serviceConfig = {
        #     KeepAlive = lib.mkForce false;
        #     RunAtLoad = lib.mkForce false;
        #   };
        # };

        nix = {
          #optimize.automatic = true; # suggested, but doesn't exist...
          linux-builder = {
            enable = false;
            ephemeral = true;
            # Not quite sure how this option works in this context, but when trying to build conduwuit for aarch64-linux in the builder,
            # I found out, after hours of googling, that I need to pass "--max-jobs 0" to nix build, to be sure _only_ the VM does the building.
            # Without it, it seems macOS was building in parallel with the VM, using the VM binaries (bash), that would ofc not run on macOS,
            # leading to errors that took I while to figure out.
            # So, what I've learnt, is:
            # --max-jobs 0 - disable local builds and only use remote builders
            # --option builders '' / --builders '' - disable remote builders and only use local
            # --option substitute false - disable remote builders and only use local
            #
            # To shut down the VM, run "ssh builder@linux-builder 'shutdown now'".
            # Seems though, that the VM is started again automatically, but at least it fres some RAM.
            maxJobs = 2;
            config = {
              nix.settings.experimental-features = "nix-command flakes";
              virtualisation = {
                darwin-builder = {
                  diskSize = 40 * 1024;
                  memorySize = 8 * 1024;
                };
                cores = 6;
              };
            };
            systems = [
              "x86_64-linux"
              "aarch64-linux"
            ];
          };
          settings = {
            experimental-features = "nix-command flakes"; # Necessary for using flakes on this system.
            trusted-users = [ "@admin" "oddee" ];
          };
        };

        # Enable alternative shell support in nix-darwin.
        # programs.fish.enable = true;
        # Create /etc/zshrc that loads the nix-darwin environment.
        programs.zsh = {
          enable = true;
        };

        # Set Git commit hash for darwin-version.
        system.configurationRevision = self.rev or self.dirtyRev or null;

        # The platform the configuration will be used on.
        nixpkgs.hostPlatform = "aarch64-darwin";

        # Touch-id for sudo
        #security.pam.enableSudoTouchIdAuth = true;
        security.pam.services.sudo_local.touchIdAuth = true;

        system = {
          keyboard.enableKeyMapping = true;
          keyboard.remapCapsLockToEscape = true;

          defaults = {
            finder = {
              AppleShowAllExtensions = true;
              ShowPathbar = true;
              FXEnableExtensionChangeWarning = false;
              _FXShowPosixPathInTitle = true;
            };
          };
          # Tab between form controls and F-row that behaves as F1-F12
          # Note: gives me error about NSGlobalDomain not existing
          # NSGlobalDomain = {
          #   AppleKeyboardUIMode = 3;
          #   "com.apple.keyboard.fnState" = true;
          # };
        };

        # users.users.oddee = {
        #     name = "oddee";
        #     home = "/Users/oddee";
        # };

        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        system.stateVersion = 6;
      };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#$hostname
      darwinConfigurations = {
        "odd-mbp-m1" = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            lix-module.nixosModules.default
            configuration
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = false;
                useUserPackages = true;
                users.oddee = import ./modules/home-manager/home.nix;
              };
              users.users.oddee.home = "/Users/oddee";
            }
          ];
          specialArgs = { inherit inputs; };
        };
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."odd-mbp-m1".pkgs;
    };
}
