{ lib, config, pkgs, baseServices, basePackages, parameters }:

let
  unstable = import <unstable> {}; # use unstable channel
in {
  imports = [
    ./dynamic-dns.nix
  ];

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

  nixpkgs.overlays = [
    (self: super: 
      let
        version = "1.3.0";
      in {
        digitalocean-dynamic-dns-ip = super.pkgs.buildGoModule {
          inherit version;

          pname = "digitalocean-dynamic-dns-ip";

          src = pkgs.fetchFromGitHub {
            owner = "anaganisk";
            repo = "digitalocean-dynamic-dns-ip";
            rev = "${version}";
            sha256 = "0p2p8ag097w9xgi3vypqfac2q503yvz94rf94da309j3nvlk4y6g";
          };

          vendorSha256 = "1ygsmkzflx84wv35sc8s4dm7acslwydgg1f0dcbhcx9jcjvpnvw8";

          runVend = true;

          meta = with lib; {
            description = "Dynamic DNS client that uses DigitalOcean's DNS API";
            homepage = "https://github.com/anaganisk/digitalocean-dynamic-dns-ip";
            license = licenses.mit;
            #maintainers = with maintainers; [ nickjanus ];
            #platforms = platforms.linux ++ platforms.darwin;
          };
        };
      }
    )
  ];
 
  environment.systemPackages = with pkgs; [
    at
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
    interfaces.enp7s0.useDHCP = true;
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

  programs.digitalocean-dynamic-dns-ip = {
    enable = true;
    conf = ''
      {
        "apikey": ${parameters.do_api_key},
        "doPageSize": 20,
        "useIPv4": true,
        "useIPv6": false,
        "domains": [
          {
            "domain": "nondesignated.com",
            "records": [
              {
                "name": "@",
                "type": "A",
                "TTL": 60
              },
              {
                "name": "*",
                "type": "A",
                "TTL": 60
              }
            ]
          }
        ]
      }
    '';
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
