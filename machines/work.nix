{ lib, config, pkgs, baseServices, basePackages, parameters}:

let
  unstable = import <unstable> {}; # use unstable channel
in {
  boot = {
    kernelModules = [ "kvm-intel" "thinkpad_acpi" "thinkpad_hwmon" ];
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelParams = ["psmouse.synaptics_intertouch=0"];

    initrd.luks.devices = {
      "nixos" = {
        device = "/dev/disk/by-uuid/433b9880-1f22-4ad7-afdf-b91c4a0f537e";
        preLVM = false;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    ansible
    awscli
    bluez # bluetoothctl
    brightnessctl
    confd
    consul
    cmake
    discord
    doctl
    unstable.docker_compose
    etcd
    gimp
    git-crypt
    glide
    grepcidr
    krita
    libwacom
    mysql57
    nmap
    networkmanager
    networkmanagerapplet
    openconnect
    openjdk
    openssl
    plantuml
    powertop
    python3
    ruby
    slack
    smartmontools
    socat
    tcpdump
    vlc
    vokoscreen
    wol
    xorg.xdpyinfo
    zoom-us
  ] ++ basePackages;

  networking = {
    hostName = "janusWork";
    networkmanager = {
      enable = true;
    };
    extraHosts = ''
      10.42.0.10 hargw bucket01.hargw
      10.42.0.10 hargwwebsite bucket01.hargwwebsite
    '';
    interfaces = {
      enp0s31f6.useDHCP = true;
      wlp0s20f3.useDHCP = true;
    };
    useDHCP = false;
  };

  hardware = {
    bluetooth.enable = true;
    pulseaudio = {
      enable = true;
      support32Bit = true;
      package = pkgs.pulseaudioFull;
    };
    firmware = [
      pkgs.sof-firmware
    ];

    # Enable gpu support
    opengl.extraPackages = with pkgs;[ vaapiIntel ];
  };

  programs = {
    light.enable = true;
  };

  services = lib.recursiveUpdate baseServices {
  };
}
