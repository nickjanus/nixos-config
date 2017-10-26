{ writeText, zsh-prezto, neovim, less, go }:

let
  self = writeText "zsh-config"
    ''
      # Color output (auto set to 'no' on dumb terminals).
      zstyle ':prezto:*:*' color 'yes'

      # Set the Prezto modules to load (browse modules).
      # The order matters.
      zstyle ':prezto:load' pmodule \
        'environment' \
        'terminal' \
        'editor' \
        'history' \
        'history-substring-search'\
        'directory' \
        'spectrum' \
        'utility' \
        'git' \
        'completion' \
        'prompt' \
        'fasd' \
        'ssh' \
        'screen' \
        'nix' \
        'ruby'

      # Set the key mapping style to 'emacs' or 'vi'.
      zstyle ':prezto:module:editor' key-bindings 'vi'

      # Ignore submodules when they are 'dirty', 'untracked', 'all', or 'none'.
      #zstyle ':prezto:module:git:status:ignore' submodules 'all'

      # History Substring Search
      #
      zstyle ‘:prezto:module:history-substring-search’ color ‘yes’
      # Set the query found color.
      zstyle ‘:prezto:module:history-substring-search:color’ found ‘bg=green,fg=white,bold’
      # Set the query not found color.
      zstyle ‘:prezto:module:history-substring-search:color’ not-found ‘bg=red,fg=white,bold’

      # Set the prompt theme to load.
      # Setting it to 'random' loads a random theme.
      # Auto set to 'off' on dumb terminals.
      zstyle ':prezto:module:prompt' theme 'paradox'

      # Set the SSH identities to load into the agent.
      zstyle ':prezto:module:ssh:load' identities 'id_rsa' 'github_rsa'

      # Set syntax highlighters.
      # By default, only the main highlighter is enabled.
      zstyle ':prezto:module:syntax-highlighting' highlighters \
        'main' \
        'brackets' \
        'pattern' \
        'cursor' \
        'root'

      # Set syntax highlighting styles.
      zstyle ':prezto:module:syntax-highlighting' styles \
        'builtin' 'bg=blue' \
        'command' 'bg=blue' \
        'function' 'bg=blue'

      # Auto set the tab and window titles.
      zstyle ':prezto:module:terminal' auto-title 'yes'

      # Set the window title format.
      zstyle ':prezto:module:terminal:window-title' format '%n@%m: %s'

      # Auto start screen sessions locally and in ssh sessions
      zstyle ':prezto:module:screen:auto-start' remote 'yes'

      # Auto convert .... to ../..
      zstyle ':prezto:module:editor' dot-expansion 'yes'

      # -------------------------------------------------

      export EDITOR='${neovim}/bin/nvim'
      export VISUAL='${neovim}/bin/nvim'
      export PAGER='${less}/bin/less -R'
      export KEYTIMEOUT=1

      alias vpn='sudo openconnect --juniper vpn-nyc2.digitalocean.com/ops -u njanus --no-dtls --background --pid /var/run/openconnect.pid'
      export GOROOT='${go.out}/share/go'
      export GOPATH='/home/nick/Code/go'
      export PATH=$PATH':/home/nick/Code/go/bin'

      # Use workaround for pulse audio that depends on path currently in review: https://github.com/NixOS/nixpkgs/pull/16834
      export NIX_PATH=nixpkgs=/home/nick/Code/nixpkgs:$NIX_PATH 
    '';
in {
  environment_etc =
    [ { source = "${zsh-prezto}/runcoms/zlogin";
        target = "zlogin";
      }
      { source = "${zsh-prezto}/runcoms/zlogout";
        target = "zlogout";
      }
      { source = self;
        target = "zpreztorc";
      }
      { source = "${zsh-prezto}/runcoms/zprofile";
        target = "zprofile.local";
      }
      { source = "${zsh-prezto}/runcoms/zshenv";
        target = "zshenv.local";
      }
      { source = "${zsh-prezto}/runcoms/zshrc";
        target = "zshrc.local";
      }
    ];
}
