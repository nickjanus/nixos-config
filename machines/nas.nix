{ lib, config, pkgs, baseServices, basePackages, parameters }:

let
  unstable = import <unstable> {}; # use unstable channel
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

  docker-containers = {
    pihole = {
      image = "pihole/pihole:latest";
      extraDockerOptions = [
        "--dns=127.0.0.1"
        "--dns=1.1.1.1"
        "--hostname=pi.hole"
      ];
      environment = {
        "TZ" = "America/Boston";
        "VIRTUAL_HOST" = "pi.hole";
        "PROXY_LOCATION" = "pi.hole";
        "WEBPASSWORD" = parameters.pihole_password;
        "PIHOLE_DNS_" = "1.1.1.1";
      };
      ports = [
        "53:53/tcp"
        "53:53/udp"
        "80:80"
        "443:443"
      ];
      volumes = [
        "/opt/pihole/pihole/:/etc/pihole/"
        "/opt/pihole/dnsmasq.d/:/etc/dnsmasq.d/"
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    at
    unstable.chia
    ethtool
    fio
    handbrake
    hdparm
    lshw
    # lsiutil # derivation currently broken
    openiscsi
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
    firewall = {
      allowedTCPPorts = [
        22
        111 # nfs
        2049 # nfs
        53 # pihole
        80 # pihole
        443 # pihole
      ];
      allowedUDPPorts = [
        111 # nfs
        2049 # nfs
        53 # pihole
      ];
    };
  };

  services = lib.recursiveUpdate baseServices {
    # Disable writeback cache for hdds
    udev = {
      extraRules = ''
        ACTION=="add|change", KERNEL=="sd*[!0-9]", ENV{ID_ATA_ROTATION_RATE_RPM}=="7200", RUN+="${pkgs.sdparm}/bin/sdparm -c WCE /dev/%k"
      '';
      path = with pkgs; [
        sdparm
      ];
    };
    zfs = {
      autoScrub = {
        enable = true;
        interval = "daily";
      };
      autoSnapshot.enable = false;
      trim.enable = false; # autotrim is enabled
    };
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
