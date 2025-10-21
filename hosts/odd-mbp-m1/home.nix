{
  config,
  pkgs,
  lib,
  ...
}:
{
  # For all possible options, see: https://nix-community.github.io/home-manager/options.xhtml

  accounts = {
    # calendar = {
    #   accounts = {
    #     gmail_oddebb = { };
    #   };
    # };

    # contact = {
    #   accounts = {
    #     gmail_oddebb = { };
    #   };
    # };

    email = {
      accounts = {
        oddware_odd = {
          primary = false;
          address = "odd@oddware.net";
          realName = "Odd E. Ebbesen";
        };
        oddware_git = {
          primary = false;
          address = "git@oddware.net";
          realName = "Odd E. Ebbesen";
        };
        gmail_oddebb = {
          primary = true;
          address = "oddebb@gmail.com";
          flavor = "gmail.com";
          realName = "Odd E. Ebbesen";

          # TODO: see if I need to set this?
          # folders = {
          #   drafts = "Drafts";
          #   inbox = "Inbox";
          #   sent = "Sent";
          #   trash = "Trash";
          # };

          # The only way I could manage to get this to work, was to disable it here, then create the mail directories manually,
          # first run "notmuch", "notmuch new", and then "gmi init <mail-addr>".
          # How to get the neomutt integration working well is still TBD.
          lieer = {
            enable = false;
            settings = {
              drop_non_existing_labels = true;
              timeout = 600;
              # Service. Not sure if it works on macOS or is just systemd?
              # sync = {
              #   enable = false;
              # };
            };
          };

          neomutt = {
            enable = false;
            extraConfig = ''
              # Must override spoolfile, or set virtual_spool_file, since home-manager sets it to "+Inbox", which doesn't work with the notmuch setup
              #set spoolfile = "Inbox"
              set virtual_spool_file = yes
              set nm_exclude_tags = "spam"
              set index_format='%4C %Z %(%Y-%m-%d %H:%M) %-15.15L %s [%g]'

              macro index $ "<shell-escape>cd ${config.accounts.email.maildirBasePath}/${config.accounts.email.accounts.gmail_oddebb.maildir.path}; gmi sync<enter>" "run lieer to sync oddebb@gmail.com"
              macro index \Cf "<vfolder-from-query>" "show only messages matching a notmuch pattern"
              #macro index A "<modify-labels>+archive -unread -inbox<enter>"        # tag as Archived
              #macro index I "<modify-labels>-inbox -unread<enter>"                 # removed from inbox
              #macro index S "<modify-labels-then-hide>-inbox -unread +junk<enter>" # tag as Junk mail
              #macro index + "<modify-labels>+*<enter><sync-mailbox>"               # tag as starred
              #macro index - "<modify-labels>-*<enter><sync-mailbox>"               # tag as unstarred

              bind index,pager l modify-labels

              bind index,pager X change-vfolder

              # sidebar bindings
              bind index <left> sidebar-prev          # got to previous folder in sidebar
              bind index <right> sidebar-next         # got to next folder in sidebar
              bind index <space> sidebar-open         # open selected folder from sidebar
            '';
            # mailboxName = "Inbox";
            # mailboxType = "maildir";
            sendMailCommand = "gmi send -t -C ${config.accounts.email.maildirBasePath}/${config.accounts.email.accounts.gmail_oddebb.maildir.path}";
            showDefaultMailbox = false;
          };

          notmuch = {
            enable = false;
            neomutt = {
              enable = false;
              virtualMailboxes = [
                {
                  name = "Inbox";
                  query = "(tag:inbox -tag:promotions -tag:social -tag:updates -tag:forums) OR (tag:inbox and tag:flagged)";
                }
                {
                  name = "Promotions";
                  query = "tag:promotions";
                }
                {
                  name = "Social";
                  query = "tag:social";
                }
                {
                  name = "Updates";
                  query = "tag:updates";
                }
                {
                  name = "Forums";
                  query = "tag:forums";
                }
                {
                  name = "Starred";
                  query = "tag:flagged";
                }
                {
                  name = "Sent";
                  query = "tag:sent";
                }
                {
                  name = "Archive";
                  query = "not tag:inbox and not tag:spam";
                }
              ];
            };
          };

          passwordCommand = "echo TODO";

        };
      };
    };
  };

  home = {
    stateVersion = "25.05";

    language = {
      address = "sv_SE.UTF-8";
      base = "sv_SE.UTF-8";
      collate = "sv_SE.UTF-8";
      ctype = "sv_SE.UTF-8";
      measurement = "sv_SE.UTF-8";
      messages = "sv_SE.UTF-8";
      monetary = "sv_SE.UTF-8";
      name = "sv_SE.UTF-8";
      numeric = "sv_SE.UTF-8";
      paper = "sv_SE.UTF-8";
      telephone = "sv_SE.UTF-8";
      time = "sv_SE.UTF-8";
    };

    # Extra entries to add to PATH
    sessionPath = [
      "/opt/homebrew/bin"
      "$HOME/.orbstack/bin"
      "$HOME/.cargo/bin"
      # "$HOME/.rd/bin"
    ];

    sessionVariables = {
      GOPATH = "$HOME/gopath";
      GOWS = "$HOME/ResilioSync/code/go/github.com/oddlid";
      RUSTWS = "$HOME/ResilioSync/code/rust";
      # EDITOR = "nvim"; # will be set by the neovim config below
      VISUAL = "$EDITOR";
      LESS = "FRi"; # --quit-if-one-screen --RAW-CONTROL-CHARS --ignore-case
      PAGER = "less";
      MANPAGER = "nvim +Man!";
      REPORTTIME = "5";
      TIMEFMT = "%U user, %S system, %P cpu, %*Es total";
      DOTNET_ROOT = "/usr/local/share/dotnet";
    };

    # TODO: see if I need to specify these, as it seems those enabled via programs.* don't need an entry here
    packages = with pkgs; [
      bat
      cargo
      fzf
      fzf-git-sh
      fzf-zsh
      ripgrep
      tmuxPlugins.tmux-fzf
      zsh-forgit
      zsh-fzf-history-search
      zsh-fzf-tab
    ];

    shell = {
      enableBashIntegration = true;
      enableShellIntegration = true;
      enableZshIntegration = true;
    };

    shellAliases = {
      _tm = "tmux -u2 attach-session || tmux -u2";
    };

    username = "oddee";
  };

  programs = {
    bash = {
      enable = true;
      enableCompletion = true;
      enableVteIntegration = true;
    };

    bat = {
      enable = true;
      config = {
        theme = "Solarized (dark)";
      };
      extraPackages = with pkgs.bat-extras; [
        batdiff
        batman
        batgrep
        batwatch
      ];
    };

    # Only one diff highlighter can be enabled at a time
    delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        navigate = true;
        side-by-side = true;
      };
    };

    diff-highlight = {
      enable = false;
    };

    diff-so-fancy = {
      enable = false;
    };

    # Not really needed anymore, after enabling eza
    dircolors = {
      enable = false;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    eza = {
      enable = true;
      colors = "auto";
      enableBashIntegration = true;
      enableZshIntegration = true;
      git = true;
      icons = "auto";
    };

    fd = {
      enable = true;
      hidden = true;
      ignores = [
        ".git/"
        "*.bak"
      ];
    };

    fzf = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      changeDirWidgetCommand = "fd --type d --strip-cwd-prefix --hidden -E .git -E .direnv";
      changeDirWidgetOptions = [
        "--preview 'eza --tree --color=always {} | head -200'"
      ];
      # Taken from the Solarized example here: https://github.com/junegunn/fzf/wiki/Color-schemes
      # In tmux, terminal must be tmux-256color, and the term overrides must also be set as below for it to work properly
      colors = {
        "bg+" = "#073642";
        bg = "#002b36";
        spinner = "#719e07";
        hl = "#586e75";
        fg = "#839496";
        header = "#586e75";
        info = "#cb4b16";
        pointer = "#719e07";
        marker = "#719e07";
        "fg+" = "#839496";
        prompt = "#719e07";
        "hl+" = "#719e07";
      };
      defaultCommand = "fd --type f --strip-cwd-prefix --hidden -E .git -E .direnv";
      # defaultOptions = [
      #   "--preview 'if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi'"
      # ];
      fileWidgetCommand = "fd --type f --strip-cwd-prefix --hidden -E .git -E .direnv";
      fileWidgetOptions = [
        "--preview 'if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi'"
      ];
      tmux = {
        enableShellIntegration = true;
      };
    };

    gh = {
      enable = true;
      settings = {
        aliases = { };
        editor = "nvim";
      };
    };

    git = {
      enable = true;
      settings = {
        alias = {
          st = "status";
          ls-untracked = "!git ls-files --others --exclude-standard";
          pushall = "!git remote | xargs -L1 git push --all";
          pushreview = "push origin HEAD:refs/for/master";
          pushdraft = "push origin HEAD:refs/drafts/master";
          count-lines = "! git log --author=\"$1\" --pretty=tformat: --numstat | awk '{ add += $1; subs += $2; loc += $1 - $2 } END { printf \"added lines: %s, removed lines: %s, total lines: %s\\n\", add, subs, loc }' #";
        };
        pull = {
          rebase = true;
        };
        user = {
          name = "git@oddware.net";
          email = "Odd E. Ebbesen";
        };
      };
      lfs.enable = true;
    };

    gpg = {
      enable = true;
    };

    htop = {
      enable = true;
      settings = { };
    };

    jq = {
      enable = true;
    };

    # Just keeping it for reference
    k9s = {
      enable = false;
    };

    lazygit = {
      enable = true;
      settings = { };
    };

    less = {
      enable = true;
    };

    lesspipe = {
      enable = true;
    };

    lf = {
      enable = true;
      cmdKeybindings = { };
      commands = { };
      keybindings = { };
      settings = { };
    };

    lieer = {
      enable = false;
    };

    # mbsync = {
    #   enable = false;
    # };

    # msmtp = {
    #   enable = false;
    # };

    neomutt = {
      enable = false;
      sidebar = {
        enable = true;
      };
      sort = "reverse-last-date-received";
      unmailboxes = true;
      vimKeys = false;
    };

    neovim = {
      enable = true;
      defaultEditor = true;
    };

    nix-your-shell = {
      enable = true;
    };

    notmuch = {
      enable = false;
    };

    ripgrep = {
      enable = true;
    };

    # For reference, to checkout later
    sftpman = {
      enable = false;
    };

    tmux = {
      enable = true;
      clock24 = true;
      escapeTime = 40;
      focusEvents = true;
      historyLimit = 5000;
      mouse = true;
      newSession = true;
      prefix = "C-x";
      sensibleOnTop = false; # see: https://github.com/nix-community/home-manager/issues/5952
      # shell = "${pkgs.zsh}/bin/zsh"; # the shell option in extraConfig seems to work better
      terminal = "tmux-256color"; # This makes the fzf colorscheme work properly

      plugins = with pkgs.tmuxPlugins; [
        continuum
        logging
        pain-control
        resurrect
        tmux-fzf
        {
          plugin = power-theme;
          extraConfig = ''
            set -g @tmux_power_theme 'moon'
            set -g @tmux_power_prefix_highlight_pos 'LR'
          '';
        }
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

        # recommendations for vim-tpipeline
        # set -g status-style bg=default
        # set -g status-left-length 90
        # set -g status-right-length 90
        # set -g status-justify centre
        # set -g status-right '#{prefix_highlight}#(hostname) | %Y-%m-%d %H:%M'
        # set-window-option -g window-status-separator " "
        # set-window-option -g window-status-current-format "#[fg=colour66]#W"
        # set-window-option -g window-status-format "#W"
      '';
    };

    # TODO: check if it's better to enable it here, or via global packages, and how to set up nix-mac-util, or whatsitsname...
    wezterm = {
      enable = false;
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      enableVteIntegration = true;
      autosuggestion = {
        enable = true;
        strategy = [
          "history"
        ];
      };
      history = {
        append = false;
        expireDuplicatesFirst = true;
        extended = true;
        save = 100000;
        saveNoDups = true;
        share = true;
      };
      historySubstringSearch = {
        enable = true;
      };
      initContent =
        let
          zCfgBeforeCompInit = lib.mkOrder 550 ''
            fpath+=(/Applications/OrbStack.app/Contents/Resources/completions/zsh)
          '';
          zCfg = lib.mkOrder 1000 ''
            if [ -x "$(which tailscale)" ]; then
              source <("$(which tailscale)" completion zsh)
            fi

            source ${pkgs.fzf-git-sh}/share/fzf-git-sh/fzf-git.sh
          '';
        in
        lib.mkMerge [
          zCfgBeforeCompInit
          zCfg
        ];
      localVariables = { };
      oh-my-zsh = {
        enable = true;
        extraConfig = ''
          zstyle :omz:plugins:ssh-agent identities id_rsa id_ed25519 github
        '';
        plugins = [
          "alias-finder"
          "aliases"
          "dircycle"
          "docker"
          "encode64"
          "extract"
          "fzf"
          "git"
          "golang"
          "helm"
          "isodate"
          "macos"
          "nmap"
          "rsync"
          "safe-paste"
          "systemadmin"
          "tmux"
          "transfer"
          "universalarchive"
          "urltools"
        ];
        theme = "crcandy";
      };
      syntaxHighlighting = {
        enable = true;
        highlighters = [
          "brackets"
        ];
        patterns = { };
        styles = { };
      };
    };

  };

  services = {
    gpg-agent = {
      enable = false;
    };

    # TODO: checkout - some gmail sync service
    lieer = {
      enable = false;
    };
  };

  # TODO: have a look at the options in target.darwin, as they contain a lot of settings for macOS

}
