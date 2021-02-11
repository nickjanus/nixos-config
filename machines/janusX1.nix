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
    extraHosts = ''
      10.42.0.10 hargw bucket01.hargw
      10.42.0.10 hargwwebsite bucket01.hargwwebsite
    '';
  };

  hardware = {
    bluetooth.enable = false;
    pulseaudio = {
      enable = true;
        support32Bit = true;
    };

    # Enable gpu support
    opengl.extraPackages = with pkgs;[ vaapiIntel ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.bash.enableCompletion = true;
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  services = lib.recursiveUpdate baseServices {
    autorandr = {
      enable = true;
      defaultTarget = "laptop";
    };
    xserver = {
      # TODO port libinput settings over to sway config
      # Enable support for wacom tablet
      wacom.enable = true;
    };
  };
}
