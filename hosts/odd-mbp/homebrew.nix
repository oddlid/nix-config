{
  ...
}:
{
  # I'd like to not use homebrew, but nice to have a fallback if there are packages
  # not available in nix
  homebrew = {
    enable = true;
    global = {
      autoUpdate = true;
    };
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
    brews = [
      "plakar" # backup system
      "syncthing"
    ];
    caskArgs.no_quarantine = true;
    casks = [
      # {
      #   name = "font-hack-nerd-font";
      #   greedy = true;
      # }
      # {
      #   name = "font-jetbrains-mono";
      #   greedy = true;
      # }
      # {
      #   name = "font-inconsolata";
      #   greedy = true;
      # }
      {
        name = "ghostty";
        greedy = true;
      }
      # {
      #   name = "google-drive";
      #   greedy = true;
      # }
      {
        name = "jump-desktop-connect";
        greedy = true;
      }
      # {
      #   name = "keepassxc";
      #   greedy = true;
      # }
      {
        name = "orbstack";
        greedy = true;
      }
      {
        name = "resilio-sync";
        greedy = true;
      }
      {
        name = "tailscale-app";
        greedy = true;
      }
      # {
      #   name = "utm";
      #   greedy = true;
      # }
      # {
      #   name = "vivaldi";
      #   greedy = true;
      # }
    ];
  };
}
