{
  description = "nix-darwin system flake for odd-mbp-m1";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, nixvim }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      # Think I want to just have the bare minimum shell tools here, and solve 
      # the rest with home-manager.
      environment.systemPackages = with pkgs; [ 
          fzf
          fzf-git-sh
          fzf-zsh
          htop
          neovim
          tmux
          tmuxPlugins.tmux-fzf
          zsh
          zsh-forgit
          zsh-fzf-history-search
          zsh-fzf-tab
          git
          #brave
          #cloudflare-warp
          #cloudflared
          #element-desktop
          #google-chrome
          #warp-terminal
          #wezterm
          #nheko
          #resilio-sync
          #signal-desktop
          #keepassxc
      ];

      # This would overwrite /etc/shells, so leaving this commented for now
      # environment.shells = [ pkgs.zsh ];

      # I'd like to not use homebrew, but nice to have a fallback if there are packages 
      # not available in nix
      homebrew = {
        enable = true;
        casks = [
          #"wezterm"
        ];
      };

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

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

      users.users.oddee = {
          name = "oddee";
          home = "/Users/oddee";
      };

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."odd-mbp-m1" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."odd-mbp-m1".pkgs;
  };
}
