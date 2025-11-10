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
      "sendme"
      "syncthing"
    ];
    caskArgs.no_quarantine = true;
    casks = [
      {
        name = "ghostty";
        greedy = true;
      }
      {
        name = "jump-desktop-connect";
        greedy = true;
      }
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
    ];
  };
}
