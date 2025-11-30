{
  config,
  lib,
  pkgs,
  ...
}:

{
  home = {
    stateVersion = "25.05";
    sessionVariables = {
      VISUAL = "nvim";
      PAGER = "less";

      LANG = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";
      MANPAGER = "sh -c 'awk '\''{ gsub(/\x1B\[[0-9;]*m/, \"\", \$0); gsub(/.\x08/, \"\", \$0); print }'\'' | bat -p -lman'";

      HOMEBREW_NO_ANALYTICS = "1";
    };
    sessionPath = [
      "${config.home.homeDirectory}/go/bin"
    ];
  };

  xdg.enable = true;
  xdg.configFile."nvim".source = ../../nvim;
  xdg.configFile."yazi/theme.toml".source = ../../yazi/theme.toml;

  programs = {
    bat = {
      enable = true;
      config = {
        theme = "Catppuccin Mocha";
      };
    };
    fzf = {
      enable = true;
      fileWidgetOptions = [
        "--walker-skip .git,node_modules,target"
        "--preview 'bat -n --color=always {}'"
        "--bind 'ctrl-/:change-preview-window(down|hidden|)'"
      ];
    };
    git = {
      enable = true;
      ignores = [ ".DS_Store" ];
      settings = {
        commit.gpgsign = true;
        diff.colorMoved = "default";
        filter.lfs = {
          clean = "git-lfs clean -- %f";
          smudge = "git-lfs smudge -- %f";
          process = "git-lfs filter-process";
          required = true;
        };
        gpg.ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
        init.defaultBranch = "main";
        merge.conflictStyle = "diff3";
        pull.rebase = "false";
        push.autoSetupRemote = true;
        user = {
          name = "Matthew Vance";
          email = "mavance44@gmail.com";
        };
      };
      signing = {
        format = "ssh";
        key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID/G8WN10/FlsokXrjIJ2C7Ev70Q8OL66dSfRXmP94hU";
      };
    };

    ghostty = {
      enable = true;
      package = null; # Use homebrew version
      settings = {
        font-size = 14;
        font-family = "JetBrains Mono";
        theme = "Catppuccin Mocha";
      };
    };

    home-manager.enable = true;

    lazydocker.enable = true;
    lazygit = {
      enable = true;
      settings = {
        disableStartupPopups = true;
        os = {
          editPreset = "nvim";
        };
        gui = {
          nerdFontsVersion = "3";
          theme = {
            activeBorderColor = [
              "#89b4fa"
              "bold"
            ];
            inactiveBorderColor = [
              "#a6adc8"
            ];
            optionsTextColor = [
              "#89b4fa"
            ];
            selectedLineBgColor = [
              "#313244"
            ];
            cherryPickedCommitBgColor = [
              "#45475a"
            ];
            cherryPickedCommitFgColor = [
              "#89b4fa"
            ];
            unstagedChangesColor = [
              "#f38ba8"
            ];
            defaultFgColor = [
              "#cdd6f4"
            ];
            searchingActiveBorderColor = [
              "#f9e2af"
            ];
          };
        };
      };
    };

    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };

    starship = {
      enable = true;
      settings = {
        aws = {
          symbol = "  ";
        };
        buf = {
          symbol = " ";
        };
        c = {
          symbol = " ";
        };
        conda = {
          symbol = " ";
        };
        crystal = {
          symbol = " ";
        };
        dart = {
          symbol = " ";
        };
        directory = {
          read_only = " 󰌾";
        };
        docker_context = {
          symbol = " ";
        };
        elixir = {
          symbol = " ";
        };
        elm = {
          symbol = " ";
        };
        fennel = {
          symbol = " ";
        };
        fossil_branch = {
          symbol = " ";
        };
        git_branch = {
          symbol = " ";
        };
        golang = {
          symbol = " ";
        };
        guix_shell = {
          symbol = " ";
        };
        haskell = {
          symbol = " ";
        };
        haxe = {
          symbol = " ";
        };
        hg_branch = {
          symbol = " ";
        };
        hostname = {
          ssh_symbol = " ";
        };
        java = {
          symbol = " ";
        };
        julia = {
          symbol = " ";
        };
        kotlin = {
          symbol = " ";
        };
        lua = {
          symbol = " ";
        };
        memory_usage = {
          symbol = "󰍛 ";
        };
        meson = {
          symbol = "󰔷 ";
        };
        nim = {
          symbol = "󰆥 ";
        };
        nix_shell = {
          symbol = " ";
        };
        nodejs = {
          symbol = " ";
        };
        ocaml = {
          symbol = " ";
        };
        os.symbols = {
          Alpaquita = " ";
          Alpine = " ";
          AlmaLinux = " ";
          Amazon = " ";
          Android = " ";
          Arch = " ";
          Artix = " ";
          CentOS = " ";
          Debian = " ";
          DragonFly = " ";
          Emscripten = " ";
          EndeavourOS = " ";
          Fedora = " ";
          FreeBSD = " ";
          Garuda = "󰛓 ";
          Gentoo = " ";
          HardenedBSD = "󰞌 ";
          Illumos = "󰈸 ";
          Kali = " ";
          Linux = " ";
          Mabox = " ";
          Macos = " ";
          Manjaro = " ";
          Mariner = " ";
          MidnightBSD = " ";
          Mint = " ";
          NetBSD = " ";
          NixOS = " ";
          OpenBSD = "󰈺 ";
          openSUSE = " ";
          OracleLinux = "󰌷 ";
          Pop = " ";
          Raspbian = " ";
          Redhat = " ";
          RedHatEnterprise = " ";
          RockyLinux = " ";
          Redox = "󰀘 ";
          Solus = "󰠳 ";
          SUSE = " ";
          Ubuntu = " ";
          Unknown = " ";
          Void = " ";
          Windows = "󰍲 ";
        };
        package = {
          symbol = "󰏗 ";
        };
        perl = {
          symbol = " ";
        };
        php = {
          symbol = " ";
        };
        pijul_channel = {
          symbol = " ";
        };
        python = {
          symbol = " ";
        };
        rlang = {
          symbol = "󰟔 ";
        };
        ruby = {
          symbol = " ";
        };
        rust = {
          symbol = "󱘗 ";
        };
        scala = {
          symbol = " ";
        };
        swift = {
          symbol = " ";
        };
        zig = {
          symbol = " ";
        };
      };
    };

    yazi = {
      enable = true;
      settings = {
        mgr = {
          show_hidden = true;
          scrolloff = 10;
        };
      };
    };

    zoxide = {
      enable = true;
      options = [
        "--cmd cd"
      ];
    };

    zsh = {
      enable = true;
      enableCompletion = true;

      defaultKeymap = "viins";

      history = {
        append = true;
        expireDuplicatesFirst = true;
        extended = true;
        findNoDups = true;
        ignoreAllDups = true;
        ignoreDups = true;
        path = "${config.xdg.dataHome}/zsh/history";
        save = 100000;
        saveNoDups = true;
        share = true;
        size = 100000;
      };

      shellAliases = {
        "..." = "cd ../..";
        "...." = "cd ../../..";
        "....." = "cd ../../../..";
        "......" = "cd ../../../../..";
        "cd.." = "cd ..";

        "-" = "cd -";
        "1" = "cd -1";
        "2" = "cd -2";
        "3" = "cd -3";
        "4" = "cd -4";
        "5" = "cd -5";
        "6" = "cd -6";
        "7" = "cd -7";
        "8" = "cd -8";
        "9" = "cd -9";

        h = "history";
        h1 = "history -10";
        h2 = "history -20";
        h3 = "history -30";
        hs = "history | fzf --border --height 50% | copy";

        copy = "pbcopy";
        paste = "pbpaste";

        a = "alias | fzf --border --height 50% | rg -o '^[^=]+' | copy";
        c = "clear";

        v = "nvim";

        ip = "curl -s https://icanhazip.com; echo";

        ls = "eza --oneline --classify --color=automatic --icons --time-style=long-iso --group-directories-first";
        la = "ls --all";
        ll = "ls --all --long --header --binary";
        sl = "ls";

        lg = "lazygit";
        lzd = "lazydocker";

        uuid = "uuidgen | tr '[:upper:]' '[:lower:]'";
        uuidc = "uuid | copy";

        path = "echo \"$PATH\" | tr ':' '\n'";
        spath = "path | fzf --border --height 50% | copy";

        ping = "ping -c 5";

        now = "date +\"%T\"";

        tf = "terraform";
        k = "kubectl";
        d = "docker";
        dc = "docker-compose";
        dr = "docker run -it --rm";

        drs = "sudo darwin-rebuild switch --flake ${config.home.homeDirectory}/code/config/nix && exec zsh";
        drr = "sudo darwin-rebuild switch --rollback --flake ${config.home.homeDirectory}/code/config/nix && exec zsh";

        cat = "bat";
      };

      siteFunctions = {
        mkcd = ''
          mkdir --parents "$1" && cd "$1"
        '';
        rop = ''
          lsof -nP -iTCP:"$1" -sTCP:LISTEN
        '';
        dru = ''
          (
            set -e
            cd ${config.home.homeDirectory}/code/config/nix
            echo "🔁 Updating nixpkgs…"
            nix flake update
            echo "⚙️ Rebuilding system…"
            sudo darwin-rebuild switch --flake .
            echo "✅ Nix upgrade complete."
          )
        '';
      };

      setOptions = [
        "AUTO_PUSHD"
        "PUSHD_IGNORE_DUPS"
        "PUSHD_MINUS"
        "ALWAYS_TO_END"
        "AUTO_LIST"
        "AUTO_MENU"
        "AUTO_PARAM_SLASH"
        "COMPLETE_IN_WORD"
        "EXTENDED_GLOB"
        "NUMERIC_GLOB_SORT"
        "INTERACTIVE_COMMENTS"
        "HASH_EXECUTABLES_ONLY"
        "NO_FLOW_CONTROL"
        "NO_MENU_COMPLETE"
      ];

      autocd = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      antidote = {
        enable = true;
        plugins = [
          "mattmc3/ez-compinit"
          "zsh-users/zsh-completions kind:fpath path:src"
          "davidde/git"
          "Aloxaf/fzf-tab"
          "zsh-users/zsh-syntax-highlighting kind:defer"
          "zsh-users/zsh-autosuggestions"
        ];
      };

      initContent = ''
        if [ -x /opt/homebrew/bin/brew ]; then
          eval "$(/opt/homebrew/bin/brew shellenv)"
        fi

        eval "$(fnm env --use-on-cd --shell zsh)"
        eval "$(docker completion zsh)"
        source <(kubectl completion zsh)
        eval "$(op completion zsh)"
      '';
    };
  };
}
