{ lib, config, pkgs, baseServices, basePackages, parameters}:

{
  # zfs things
  boot.kernelParams = [ "nohibernate" ];
  boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "0df78d94";

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.zfsSupport = true;
  boot.loader.grub.copyKernels = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.loader.grub.mirroredBoots = [
    { path = "/boot"; devices = [ "/dev/disk/by-uuid/4763-C9B8" ]; }
    { path = "/boot-fallback"; devices = [ "/dev/disk/by-uuid/47EC-AF88" ]; }
  ];
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "spring"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  networking.interfaces.enp56s0.useDHCP = true;
  networking.interfaces.enp58s0.useDHCP = true;

  hardware = {
    bluetooth.enable = true;
    opengl.driSupport32Bit = true; # lutris support
    sane.enable = true;
    xpadneo.enable = true;
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    gamescopeSession = {
      enable = true;
      args = [
        "-H 3840"
        "-W 2160"
        "-h 1920"
        "-w 1080"
        "-S integer"
        "-r 120"
      ];
    };
  };

  services = lib.recursiveUpdate baseServices {
    fwupd.enable = true;
    printing = {
      enable = true;
      drivers = [ pkgs.foo2zjs ];
    };
    zfs = {
      autoScrub = {
        enable = true;
        interval = "weekly";
      };
      autoSnapshot.enable = false;
    };
  };

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "steam"
    "steam-original"
    "steam-runtime"
  ];

  environment.systemPackages = with pkgs; [
    abcde
    cargo
    # ccextractor # used by makemkv
    cntr # used with breakpointHook
    discord
    gamescope
    gcc
    handbrake
    simple-scan
    lshw
    lutris
    makemkv
    pciutils
    protontricks
    rustc
    usbutils
    waypipe
    xorg.xrandr # used by gaming shortcut
    zoom
  ] ++ basePackages;

  system.stateVersion = "21.11";
}

