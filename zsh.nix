{ config, pkgs, parameters }:

let
  self = pkgs.writeText "zsh-config"
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
        'directory' \
        'spectrum' \
        'utility' \
        'git' \
        'completion' \
        'prompt' \
        'fasd' \
        'ssh' \
        'screen' \
        'syntax-highlighting'\
        'history-substring-search'

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
      zstyle ':prezto:module:ssh:load' identities 'id_nas' 'id_github'

      # Set syntax highlighters.
      # By default, only the main highlighter is enabled.
      zstyle ':prezto:module:syntax-highlighting' highlighters \
        'main' \
        'brackets' \
        'pattern' \
        'line' \
        'cursor' \
        'root'

      # Set syntax highlighting styles.
      # zstyle ':prezto:module:syntax-highlighting' styles \
      #   'builtin' 'bg=blue' \
      #   'command' 'bg=blue' \
      #   'function' 'bg=blue'

      # Auto set the tab and window titles.
      zstyle ':prezto:module:terminal' auto-title 'yes'

      # Set the window title format.
      zstyle ':prezto:module:terminal:window-title' format '%n@%m: %s'

      # Auto start screen sessions locally and in ssh sessions
      zstyle ':prezto:module:screen:auto-start' remote 'yes'

      # Auto convert .... to ../..
      zstyle ':prezto:module:editor' dot-expansion 'yes'

      # -------------------------------------------------

      export EDITOR='${pkgs.neovim}/bin/nvim'
      export VISUAL='${pkgs.neovim}/bin/nvim'
      export PAGER='${pkgs.less}/bin/less -R'
      export KEYTIMEOUT=1

      alias ergodox-update='sudo teensy-loader-cli --mcu=atmega32u4 -v -w'
      alias nas-up='wol a8:a1:59:08:45:e0'

      ### Work
      alias vpnup='sudo openconnect --background --protocol=gp -b -u njanus --csd-wrapper ${pkgs.openconnect}/libexec/openconnect/hipreport.sh https://vpn-nyc3.digitalocean.com/ssl-vpn'
      alias vpndown='sudo kill -s INT `pgrep openconnect`'
      alias cephcontainer='docker run --rm --name ceph \
           --network host \
           -e CEPH_DAEMON=demo \
           -e DEMO_DAEMONS=mon,osd,mgr,mds,rgw \
           -e MON_IP=127.0.0.1 \
           -e CEPH_PUBLIC_NETWORK=0.0.0.0/0 \
           -e CEPH_DEMO_UID=test_admin \
           -e CEPH_DEMO_ACCESS_KEY=test-admin \
           -e CEPH_DEMO_SECRET_KEY=zMTLJsb5oxW2XtH4xsJTkf0MgunWXreFbbdjkfPV \
           -e RGW_CIVETWEB_PORT=7480 \
           -d docker.internal.digitalocean.com/library/ceph:7f2db4f4e95b2c2d9592b670056ff55b5ee7b4f1'
      export GOROOT='${pkgs.go.out}/share/go'
      export GOPATH='/home/nick/code/go'
      export PATH=$PATH':/home/nick/code/go/bin'
      ###

      # Setup direnv
      eval "$(direnv hook zsh)"

      # Enable wayland for firefox
      export MOZ_ENABLE_WAYLAND=1

      # If running from tty1 start sway
      if [ "$(tty)" = "/dev/tty1" ]; then
        exec ${pkgs.sway}/bin/sway -d -c ${import ./i3config.nix { inherit config; inherit pkgs; inherit parameters; }} 2> ~/sway.log
      fi
    '';
in {
  environment_etc = {
    zlogin = {
      source = "${pkgs.zsh-prezto}/runcoms/zlogin";
    };
    zlogout = {
      source = "${pkgs.zsh-prezto}/runcoms/zlogout";
    };
    zpreztorc = {
      source = self;
    };
    "zprofile.local" = {
      source = "${pkgs.zsh-prezto}/runcoms/zprofile";
    };
    "zshenv.local" = {
      source = "${pkgs.zsh-prezto}/runcoms/zshenv";
    };
    "zshrc.local" = {
      source = "${pkgs.zsh-prezto}/runcoms/zshrc";
    };
  };
}
