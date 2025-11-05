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
      "cocoapods" # needed to build swift apps
      "dumbpipe"
      "plakar" # backup system
      "sendme"
      "syncthing"
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
      # {
      #   name = "beeper";
      #   greedy = true;
      # }
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
      # {
      #   name = "deskpad";
      #   greedy = true;
      # }
      {
        name = "dotnet-sdk";
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
        name = "font-jetbrains-mono";
        greedy = true;
      }
      {
        name = "font-inconsolata";
        greedy = true;
      }
      {
        name = "ghostty";
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
      # {
      #   name = "jump-desktop";
      #   greedy = true;
      # }
      {
        name = "jump-desktop-connect";
        greedy = true;
      }
      {
        name = "keepassxc";
        greedy = true;
      }
      # {
      #   name = "nheko";
      #   greedy = true;
      # }
      {
        name = "orbstack";
        greedy = true;
      }
      # {
      #   name = "orion";
      #   greedy = true;
      # }
      {
        name = "resilio-sync";
        greedy = true;
      }
      {
        name = "rustdesk";
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
        name = "tailscale-app";
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
        name = "vivaldi";
        greedy = true;
      }
      {
        name = "vlc";
        greedy = true;
      }
      # {
      #   name = "warp";
      #   greedy = true;
      # }
      # {
      #   name = "wezterm";
      #   greedy = true;
      # }
    ];
  };
}
