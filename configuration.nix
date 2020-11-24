# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, config, pkgs, ... }:

let
  parameters = import ./parameters.nix;

  baseServices = {
    locate.enable = true;

    # Swap out systemd time daemon until it works
    timesyncd.enable = false;
    ntp.enable = true;
  };

  basePackages = with pkgs; [
    ack
    alacritty
    arandr
    bat
    bc
    bind
    binutils
    calibre
    chromium
    cmus
    direnv
    efibootmgr
    efivar
    file
    firefox
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
    imagemagick7
    irssi
    jq
    lsof
    neovim
    nfs-utils
    openssh
    parted
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
    zsh
    zsh-prezto
  ];

  zsh_config = import ./zsh.nix {inherit pkgs; inherit config; inherit parameters;};

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
          inherit parameters;
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
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };
  i18n = {
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
    chromium.extraOpts="--enable-features=UseOzonePlatform --ozone-platform=wayland";
    sway = {
      enable = true;
      extraPackages = with pkgs; [ 
        bemenu
        kanshi # autorandor replacement
        kitty
        grim # screen cap
        i3status
        light
        mako
        rxvt-unicode
        swaylock
        swayidle
        wdisplays # arandr equivalent
        wl-clipboard
        xwayland
      ];
    };
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

  virtualisation.docker.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03";
}
