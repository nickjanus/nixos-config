{ lib, config, pkgs, baseServices, basePackages}:

let
in {
  boot = {
    kernelModules = [ ];
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    supportedFilesystems = [ "zfs" ];
    zfs = {
      forceImportAll = false;
      forceImportRoot = false;
    };
  };

  environment.systemPackages = with pkgs; [
    at
    ethtool
    fio
    hdparm
    lshw
    # lsiutil # derivation currently broken
    pciutils
    sdparm
    sg3_utils
    smartmontools
    zfs
  ] ++ basePackages;

  networking = {
    hostName = "janusNas";
    hostId = "49376c7c";
    useDHCP = false;
    wireless.enable = false;
    interfaces.enp5s0.useDHCP = true;
    firewall.allowedTCPPorts = [ 22 ];
  };

  hardware = {
    # Enable gpu support
    opengl.extraPackages = with pkgs;[ vaapiIntel ];
  };

  services = lib.recursiveUpdate baseServices {
    zfs = {
      autoScrub = {
        enable = true;
        interval = "Mon, 12:00";
        pools = []; # srcub all pools
      };
      autoSnapshot.enable = false;
      trim = {
        enable = true;
        interval = "weekly";
      };
    };
    xserver.enable = false;
    nfs.server.enable = true;
    openssh.enable = true;
    wakeonlan.interfaces = [
      {
        interface = "enp5s0";
        method = "magicpacket";
      }
    ];
  };
}
