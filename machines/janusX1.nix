{ lib, config, pkgs, baseServices, basePackages, parameters }:

let
  unstable = import <unstable> {}; # use unstable channel
in {
  boot = {
    kernelModules = [ "kvm-intel" "thinkpad_acpi" "thinkpad_hwmon" ];
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelParams = ["psmouse.synaptics_intertouch=0"];

    initrd.luks.devices = {
      "lvm" = {
        device = "/dev/nvme0n1p5";
        preLVM = true;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    ansible
    awscli
    # bluez # bluetoothctl
    confd
    cmake
    discord
    unstable.docker_compose
    etcd
    gimp
    git-crypt
    glide
    grepcidr
    krita
    libwacom
    mtr
    mysql57
    nmap
    networkmanager
    networkmanagerapplet
    openconnect
    openjdk
    openssl
    plantuml
    python3
    ruby
    slack
    smartmontools
    socat
    tcpdump
    terminator #temp
    vault #temp
    vlc
    wol
    zoom-us
  ] ++ basePackages;

  networking = {
    hostName = "janusX1";
    networkmanager = {
      enable = true;
      wifi.powersave = false;
    };
  };

  hardware = {
    bluetooth.enable = false;
    firmware = [
      pkgs.sof-firmware
    ];

    # Enable gpu support
    opengl.extraPackages = with pkgs;[ vaapiIntel ];
  };

  services = lib.recursiveUpdate baseServices {
  };

  programs = {
    light.enable = true;
  };

  system.stateVersion = "21.05";
}
