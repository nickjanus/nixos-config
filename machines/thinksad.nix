# This file is symlinked to ../machine.nix on my desktop

{ lib, pkgs, default_services, base_packages}:

{
  boot = {
    blacklistedKernelModules = [ "pcspkr" ];
    kernelModules = [ "kvm-intel" "thinkpad_acpi" "thinkpad_hwmon" ];
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    initrd.luks.devices = [
      {
        name = "lvm";
        device = "/dev/sda2";
        preLVM = true;
      }
    ];
  };

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

  hardware = {
    trackpoint.enable = false;
    pulseaudio = {
      enable = true;
      support32Bit = true;
    };
  };

  services = lib.recursiveUpdate default_services {
    tlp.enable = true; # Linux advanced power management
    xserver = {
      synaptics = {
        enable = true;
        twoFingerScroll = true;
        accelFactor = "0.020";
        minSpeed = "1.0";
        maxSpeed = "5.0";
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
