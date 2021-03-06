# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, config, pkgs, ... }:

let
  parameters = import ./parameters.nix;

  baseServices = {
    locate.enable = true;
    timesyncd.enable = true;
  };

  basePackages = with pkgs; [
    ack
    ag
    bat
    bc
    bind
    binutils
    calibre
    google-chrome
    cmus
    direnv
    efibootmgr
    efivar
    file
    firefox
    fwupd
    fzf
    git
    gnumake
    gnupg
    gnupg1compat
    go
    gptfdisk
    htop
    imagemagick7
    jq
    lsof
    neovim
    nfs-utils
    openssh
    parted
    pavucontrol
    s3cmd
    screen
    spotify
    sysstat
    teensy-loader-cli
    terraform
    tmux
    tree
    unzip
    wget
    zoxide
    (
      pkgs.writeTextFile {
        name = "startsway";
        destination = "/bin/startsway";
        executable = true;
        text = ''
          #! /usr/bin/env bash

          # first import environment variables from the login manager
          systemctl --user import-environment
          # then start the service
          exec systemctl --user start sway.service
        '';
      }
    )
  ];

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


  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      corefonts  # Micrsoft free fonts
      fira # monospaced
      inconsolata  # monospaced
      open-dyslexic
      powerline-fonts
      ubuntu_font_family
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
    permittedInsecurePackages = [
   ];

    packageOverrides = pkgs: rec {
      neovim = (import ./vim.nix);
    };
  };

  environment = {
    etc = {
      "sway/config".source = import ./sway.nix { inherit config; inherit pkgs; inherit parameters; };
      "fish/functions/fish_user_key_bindings.fish".source = ./fish_functions/fish_user_key_bindings.fish;
    };
  };

  # List services that you want to enable:
  programs = {
    ssh.forwardX11 = false;
    ssh.startAgent = true;
    fish = {
      enable = true;
      shellInit = ''
        set EDITOR ${pkgs.neovim}/bin/nvim
        set VISUAL ${pkgs.neovim}/bin/nvim
        set PAGER "${pkgs.less}/bin/less -R"

        fish_vi_key_bindings
        direnv hook fish | source
        zoxide init fish | source
      '';
      interactiveShellInit = ''
        startsway
      '';
      shellAbbrs = {
        ergodox-update = "sudo teensy-loader-cli --mcu=atmega32u4 -v -w";
        nas-up = "wol a8:a1:59:08:45:e0";
        grab = "grim -g (slurp)";
        # Work
        vpnup = "sudo openconnect --background --protocol=gp -b -u njanus --csd-wrapper ${pkgs.openconnect}/libexec/openconnect/hipreport.sh https://vpn-nyc3.digitalocean.com/ssl-vpn";
        vpndown = "sudo kill -s INT (pgrep openconnect)";
      };
    };
    sway = {
      enable = true;
      extraPackages = with pkgs; [ 
        bemenu
        kanshi # autorandr replacement
        kitty
        grim # screen cap
        i3status
        light
        mako
        rxvt-unicode
        slurp # for screenshot selection
        swaylock
        swayidle
        wdisplays # arandr equivalent
        wl-clipboard
        xwayland
      ];
    };
  };

  systemd = {
    user = {
      targets = {
        sway-session = {
          description = "Sway compositor session";
          documentation = [ "man:systemd.special(7)" ];
          bindsTo = [ "graphical-session.target" ];
          wants = [ "graphical-session-pre.target" ];
          after = [ "graphical-session-pre.target" ];
        };
      };
      services = {
        sway = {
          description = "Sway - Wayland window manager";
          documentation = [ "man:sway(5)" ];
          bindsTo = [ "graphical-session.target" ];
          wants = [ "graphical-session-pre.target" ];
          after = [ "graphical-session-pre.target" ];
          # We explicitly unset PATH here, as we want it to be set by
          # systemctl --user import-environment in startsway
          environment.PATH = lib.mkForce null;
          serviceConfig = {
            Type = "simple";
            ExecStart = ''
              ${pkgs.dbus}/bin/dbus-run-session ${pkgs.sway}/bin/sway --debug
            '';
            Restart = "on-failure";
            RestartSec = 1;
            TimeoutStopSec = 10;
          };
        };
        kanshi = {
          description = "Kanshi output autoconfig ";
          wantedBy = [ "graphical-session.target" ];
          partOf = [ "graphical-session.target" ];
          serviceConfig = {
            ExecStart = ''
              ${pkgs.kanshi}/bin/kanshi
            '';
            RestartSec = 5;
            Restart = "always";
          };
        };
      };
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
  users.defaultUserShell = "/run/current-system/sw/bin/fish";

  virtualisation.docker.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "21.05";
}
