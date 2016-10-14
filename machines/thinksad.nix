# This file is symlinked to ../machine.nix on my desktop

{ lib, pkgs, default_services, base_packages}:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices = [
    {
      name = "lvm";
      device = "/dev/sda2";
      preLVM = true;
    }
  ];

  environment.systemPackages = with pkgs; [
    # Development dependencies
    ruby_2_1
    bundix
    bundler
    php
    mysql
    pdsh
    awscli
    hipchat
  ] ++ base_packages;

  networking.hostName = "thinksad"; # Define your hostname.
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  hardware.trackpoint.enable = false;
  services = lib.recursiveUpdate default_services {
    xserver = {
      synaptics = {
        enable = true;
        twoFingerScroll = true;
        maxSpeed = "2.0";
        palmDetect = true;
        tapButtons = false;
        vertEdgeScroll = false;
        additionalOptions = ''
          Option "ClickPad" "true"
          Option "EmulateMidButtonTime" "0"
        '';
      };
    };
  };
}
