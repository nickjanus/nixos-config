{ lib, config, pkgs, baseServices, basePackages}:

{
  boot = {
    kernelModules = [ "kvm-intel" "thinkpad_acpi" "thinkpad_hwmon" ];
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

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
    confd
    cmake
    docker_compose
    etcd
    git-crypt
    nmap
    networkmanagerapplet
    openconnect
    openjdk
    openssl
    plantuml
    ruby
    slack
    tcpdump
    vagrant
    xorg.xdpyinfo
    xorg.xbacklight
    zoom-us
  ] ++ basePackages;

  networking = {
    hostName = "janusX1";
    networkmanager = {
      enable = true;
      useDnsmasq = true;
    };
    extraHosts = ''
      10.42.0.10 hargw bucket01.hargw
      10.42.0.10 hargwwebsite bucket01.hargwwebsite
    '';
  };

  hardware = {
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
      monitorSection = ''
        DisplaySize 309 174
      '';
      displayManager.sessionCommands = ''
        # HiDPI
        export GDK_SCALE=2
        export GDK_DPI_SCALE=0.625
      '';

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

  virtualisation.docker.enable = true;
  virtualisation.virtualbox.host = {
    enable = true;
    headless = true;
  };
}
