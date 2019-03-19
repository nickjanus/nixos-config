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
    awscli
    arandr
    bluez # bluetoothctl
    confd
    consul
    cmake
    discord
    docker_compose
    etcd
    git-crypt
    mysql57
    nmap
    networkmanager
    networkmanagerapplet
    unstable.openconnect
    openjdk
    openssl
    plantuml
    powertop
    ruby
    slack
    socat
    tcpdump
    xorg.xdpyinfo
    xorg.xbacklight
    zoom-us
  ] ++ basePackages;

  networking = {
    hostName = "janusX1";
    networkmanager = {
      enable = true;
      useDnsmasq = false; #TODO Reenable once networkmanager can handle gp
    };
    extraHosts = ''
      10.42.0.10 hargw bucket01.hargw
      10.42.0.10 hargwwebsite bucket01.hargwwebsite
    '';
  };

  hardware = {
    bluetooth.enable = true;
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
      serverFlagsSection = ''
        Option "BlankTime" "10"
        Option "StandbyTime" "20"
        Option "SuspendTime" "20"
        Option "OffTime" "0"
      '';

      xkbOptions = "altwin:prtsc_rwin, terminate:ctrl_alt_bksp";
    };
  };
}
