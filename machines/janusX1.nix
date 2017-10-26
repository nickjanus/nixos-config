{ lib, config, pkgs, baseServices, basePackages}:

let 
  pulseFix =  pkgs.fetchgit {
    url = "git://github.com/nickjanus/pulseaudio-x1";
    rev = "9e7722f61dd09285b309968bae36a17cad5231bc";
    sha256 = "1jfnvvq134py223iyzsminvq7gbiz71qgdknmyg9xaiiqjwmbq4q";
  };
in
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
    arandr
    docker_compose
    nmap
    openconnect
    slack
    vagrant
    xorg.xdpyinfo
    xorg.xbacklight
    zoom-us
  ] ++ basePackages;

  networking.hostName = "janusX1";
  networking.wireless.enable = true;

  hardware = {
    pulseaudio = {
      enable = true;
      support32Bit = true;
      packages = [ pulseFix.outPath ];
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
    # tlp.enable = true; # Linux advanced power management
    # thinkfan = {
    #   enable = true;
    #   sensor = "/sys/devices/virtual/thermal/thermal_zone0/temp";
    # };
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
      # synaptics = {
      #   enable = true;
      #   horizontalScroll = false;
      #   vertEdgeScroll = false;
      #   twoFingerScroll = false;
      #   accelFactor = "0.10";
      #   minSpeed = "1.0";
      #   maxSpeed = "4.0";
      #   tapButtons = false;
      #   palmDetect = true;
      # };
      xkbOptions = "altwin:prtsc_rwin, terminate:ctrl_alt_bksp";
    };
  };

  virtualisation.docker.enable = true;
  virtualisation.virtualbox.host = {
    enable = true;
    headless = true;
  };
}
