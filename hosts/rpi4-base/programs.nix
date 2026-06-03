{ pkgs, ... }:
{
  programs = {

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    less = {
      enable = true;
      envVariables = {
        LESS = "FRi"; # --quit-if-one-screen --RAW-CONTROL-CHARS --ignore-case
      };
    };

    neovim = {
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      # I might like to change these, so specified as a reminder
      withNodeJs = false;
      withPython3 = false;
      withRuby = false;
    };

    nh = {
      enable = true;
      # Use either this or nix.gc.automatic, not both
      clean = {
        enable = false;
      };
      # flake = ""; # TODO: set when path decided
    };

    tmux = {
      enable = true;
      clock24 = true;
      escapeTime = 40;
      historyLimit = 5000;
      newSession = true;
      terminal = "tmux-256color"; # This makes the fzf colorscheme work properly

      plugins = with pkgs.tmuxPlugins; [
        continuum
        logging
        pain-control
        resurrect
        tmux-fzf
        prefix-highlight
        yank
      ];

      extraConfig = ''
        # See: https://github.com/tmux/tmux/wiki/Clipboard#quick-summary
        set -s set-clipboard on
        # Ms modifies OSC 52 clipboard handling to work with mosh, see
        # https://gist.github.com/yudai/95b20e3da66df1b066531997f982b57b
        set -ag terminal-overrides ",xterm*:Ms=\\E]52;c%p1%.0s;%p2%s\\7"
        set -ag terminal-overrides ",tmux*:Ms=\\E]52;c%p1%.0s;%p2%s\\7"

        bind-key x send-prefix
        bind-key C-x last-window
        bind 'v' copy-mode
        set-window-option -g mode-keys vi
        set -g default-command "$SHELL"
        set -g default-shell "$SHELL"
        set -ag terminal-overrides ',xterm-256color:Tc'
        set -as terminal-overrides ',xterm*:sitm=\E[3m'
        # allow for navigating between words with option
        set-window-option -g xterm-keys on
        # Allow the arrow key to be used immediately after changing windows
        set -g repeat-time 0
        # Set window notifications
        set -g monitor-activity on
        set -g visual-activity on
        # Status update interval
        set -g status-interval 1
        set -g renumber-windows on    # renumber windows when a window is closed
      '';
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestions = {
        enable = true;
        strategy = [
          "history"
        ];
      };
      syntaxHighlighting = {
        enable = true;
        highlighters = [
          "brackets"
        ];
        # patterns = { };
        # styles = { };
      };
    };

  };
}
