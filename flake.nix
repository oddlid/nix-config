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
          username = "oddee";
        in
        {
          rpi4 = nixos-raspberrypi.lib.nixosInstaller {
            system = "aarch64-linux";
            specialArgs = inputs;
            modules = [
              ./hosts/rpi4-base/base.nix
              ./hosts/rpi4-base/environment.nix
              (import ./hosts/rpi4-base/networking.nix { hostname = "rpi4-base"; })
              ./hosts/rpi4-base/programs.nix
              ./hosts/rpi4-base/security.nix
              (import ./hosts/rpi4-base/services.nix { primaryUser = username; })
              ./hosts/rpi4-base/system.nix
              ./hosts/rpi4-base/systemd.nix
              (import ./hosts/rpi4-base/users.nix { primaryUser = username; })
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
