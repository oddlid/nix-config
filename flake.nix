{
  description = "Nix configuration for Oddware systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.92.0.tar.gz";
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
          coreutils-full
          devenv
          git
          nodejs_23 # Common for a lot of nvim stuff, so might just always have it
          rclone
          vim
          zsh
        ];

        # This would overwrite /etc/shells, so leaving this commented for now
        # environment.shells = [ pkgs.zsh ];

        # I'd like to not use homebrew, but nice to have a fallback if there are packages 
        # not available in nix
        homebrew = {
          enable = false;
          global = {
            autoUpdate = true;
          };
          onActivation = {
            autoUpdate = true;
            cleanup = "uninstall";
            upgrade = true;
          };
          casks = [
            {
              name = "adobe-digital-editions";
              greedy = true;
            }
            {
              name = "android-studio";
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
            {
              name = "chirp";
              greedy = true;
            }
            {
              name = "cloudflare-warp";
              greedy = true;
            }
            {
              name = "element";
              greedy = true;
            }
            {
              name = "font-hack-nerd-font";
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
              name = "keepassxc";
              greedy = true;
            }
            {
              name = "nheko";
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

        nix = {
          #optimize.automatic = true; # suggested, but doesn't exist...
          linux-builder = {
            enable = true;
            ephemeral = true;
            maxJobs = 4;
            config = {
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
        security.pam.enableSudoTouchIdAuth = true;

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
