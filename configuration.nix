# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, config, pkgs, ... }:

let
  parameters = import ./parameters.nix;
  unstable = import <unstable> {}; # use unstable channel

  baseServices = {
    locate.enable = true;
    xserver = {
      autorun = true;
      enable = true;
      layout = "us";
      windowManager.i3.enable = true;
      windowManager.i3.configFile = import ./i3config.nix { inherit config; inherit pkgs; inherit parameters; };
      windowManager.default = "i3";
      displayManager.slim = {
        enable = true;
        defaultUser = "nick";
      };
    };
  };

  basePackages = with pkgs; [
    ack
    alacritty
    arandr
    bind
    binutils
    calibre
    unstable.chromium
    cmus
    direnv
    dmenu
    efibootmgr
    elixir
    file
    unstable.firefox
    fwupd
    gcc
    git
    git-lfs
    gnumake
    gnupg
    gnupg1compat
    go
    gptfdisk
    htop
    i3
    i3status
    imagemagick7
    inotify-tools # used by phoenix
    irssi
    jq
    lsof
    maim # screenshot tool
    neovim
    openssh
    pavucontrol
    s3cmd
    screen
    signal-desktop
    sysstat
    teensy-loader-cli
    terminator
    terraform
    tmux
    tree
    unzip
    vagrant
    wget
    xlibs.xev
    xsel
    zsh
    zsh-prezto
  ];

  zsh_config = import ./zsh.nix {
    inherit (pkgs) writeText zsh-prezto neovim less go;
  };

in {
  imports =
    [ # Include the results of the hardware scan.
      (./hardware-configurations + "/${parameters.machine}.nix")
      # Machine specific config
      (
        import (./machines + "/${parameters.machine}.nix") {
          inherit lib;
          inherit config;
          inherit pkgs;
          inherit baseServices;
          inherit basePackages;
        }
      )
    ];

  environment.etc = zsh_config.environment_etc;

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      corefonts  # Micrsoft free fonts
      fira # monospaced
      inconsolata  # monospaced
      open-dyslexic
      powerline-fonts
      ubuntu_font_family  # Ubuntu fonts
      unifont # some international languages
    ];
  };

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  nixpkgs.config = {
    allowUnfree = true;

    packageOverrides = pkgs: rec {
      neovim = (import ./vim.nix);
    };
  };

  # List services that you want to enable:
  programs = {
    ssh.forwardX11 = false;
    ssh.startAgent = true;
    zsh.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.nick = {
    home = "/home/nick";
    description = "Nick Janus";
    extraGroups = [ 
      "docker"
      "networkmanager"
      "video"
      "wheel"
    ];
    isNormalUser = true;
    uid = 1000;
  };
  users.defaultUserShell = "/run/current-system/sw/bin/zsh";

  systemd.services.lockOnClose = {
    description = "Lock X session using slimlock";
    wantedBy = [ "sleep.target" ];
    serviceConfig = {
      User = "nick";
      ExecStart = "${pkgs.slim}/bin/slimlock";
    };
  };

  virtualisation.docker.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09";
}
