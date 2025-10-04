{
  description = "Nix configuration for Oddware systems";

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

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    # Optional: Declarative tap management
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
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
    in
    {
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
                useGlobalPkgs = false;
                useUserPackages = true;
                users.oddee = import ./hosts/odd-mbp-m1/home.nix;
              };
              users.users.oddee.home = "/Users/oddee";
            }
          ];
          specialArgs = { inherit inputs; };
        };

        "odd-mbp" = darwin.lib.darwinSystem {
          system = "x86_64-darwin";
          modules = [
            ./nix-cfg.nix
            ./hosts/odd-mbp/systempackages.nix
            ./hosts/odd-mbp/homebrew.nix
            ./hosts/odd-mbp/security.nix
            ./hosts/odd-mbp/nixpkgs.nix
            (import ./hosts/odd-mbp/system.nix { inherit self; })
            configuration
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                enable = true;
                enableRosetta = false;
                user = "oddee";
                autoMigrate = true;
              };
            }
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = false;
                useUserPackages = true;
                users.oddee = import ./hosts/odd-mbp/home.nix;
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
