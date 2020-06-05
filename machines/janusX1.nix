{ lib, config, pkgs, baseServices, basePackages}:

let
  unstable = import <unstable> {}; # use unstable channel
in {
  boot = {
    kernelModules = [ "kvm-intel" "thinkpad_acpi" "thinkpad_hwmon" ];
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelParams = ["psmouse.synaptics_intertouch=0"];

    initrd.luks.devices = [
      {
        name = "lvm";
        device = "/dev/nvme0n1p5";
        preLVM = true;
      }
    ];
  };

  environment.systemPackages = with pkgs; [
    ansible
    awscli
    arandr
    # bluez # bluetoothctl
    confd
    consul
    cmake
    discord
    unstable.docker_compose
    etcd
    git-crypt
    glide
    light
    mysql57
    nmap
    networkmanager
    networkmanagerapplet
    python3
    unstable.openconnect
    openjdk
    openssl
    plantuml
    powertop
    ruby
    slack
    socat
    tcpdump
    vlc
    vokoscreen
    wol
    xorg.xdpyinfo
    zoom-us
  ] ++ basePackages;

  networking = {
    hostName = "janusX1";
    networkmanager = {
      enable = true;
    };
    extraHosts = ''
      10.42.0.10 hargw bucket01.hargw
      10.42.0.10 hargwwebsite bucket01.hargwwebsite
    '';
  };

  hardware = {
    bluetooth.enable = false;
    brightnessctl.enable = true;
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
    xserver = {
      dpi = 120;

      # Enable touchpad support.
      libinput = {
        enable = true;
        accelSpeed = "0.25";
        clickMethod = "clickfinger";
        middleEmulation = false;
        naturalScrolling = true;
        tapping = false;
      };

      xkbOptions = "altwin:prtsc_rwin, terminate:ctrl_alt_bksp";
    };
  };
}
