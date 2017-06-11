{ lib, config, pkgs, baseServices, basePackages}:

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
    arandr
    hipchat
    nmap
    xorg.xbacklight
    vagrant # because bundix is a :-(
    zoom-us
  ] ++ basePackages;

  networking.hostName = "thinksad"; # Define your hostname.
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.extraHosts = ''
    127.0.0.1 juno.acquia.com
    127.0.0.1 beta.juno.acquia.com
  '';

  hardware = {
    trackpoint.enable = false;
    pulseaudio = {
      enable = true;
        support32Bit = true;
    };
  };

  services = lib.recursiveUpdate baseServices {
    tlp.enable = true; # Linux advanced power management
    thinkfan = {
      enable = true;
      sensor = "/sys/devices/virtual/thermal/thermal_zone0/temp";
    };
    xserver = {
      synaptics = {
        enable = true;
        horizontalScroll = false;
        vertEdgeScroll = false;
        twoFingerScroll = false;
        accelFactor = "0.10";
        minSpeed = "1.0";
        maxSpeed = "4.0";
        tapButtons = false;
        palmDetect = true;
      };
      xkbOptions = "altwin:prtsc_rwin, terminate:ctrl_alt_bksp";
    };
  };

  virtualisation.docker.enable = true;
  virtualisation.virtualbox.host = {
    enable = true;
    headless = true;
  };
}
