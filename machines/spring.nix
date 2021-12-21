{ lib, config, pkgs, baseServices, basePackages, parameters}:

{
  # zfs things
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.kernelParams = [ "nohibernate" ];
  boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "0df78d94";

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.zfsSupport = true;
  boot.loader.grub.copyKernels = true;

  # swap these once booting in uefi
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.grub.efiInstallAsRemovable = true;

  boot.loader.grub.mirroredBoots = [
    { path = "/boot"; devices = [ "/dev/disk/by-uuid/4763-C9B8" ]; }
    { path = "/boot-fallback"; devices = [ "/dev/disk/by-uuid/47EC-AF88" ]; }
  ];
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";

  networking.hostName = "spring"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp56s0.useDHCP = true;
  networking.interfaces.enp58s0.useDHCP = true;

  hardware = {
    bluetooth.enable = true;
  };

  programs.steam.enable = true;

  services = lib.recursiveUpdate baseServices {
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
    discord
    gcc
    lshw
    pciutils
    rustc
    usbutils
  ] ++ basePackages;

}

