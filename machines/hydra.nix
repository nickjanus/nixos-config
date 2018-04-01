{ lib, config, pkgs, baseServices, basePackages}:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices = [
    {
      name = "nixos";
      device = "/dev/VolGroup/nixos";
      preLVM = false;
    }
  ];

  networking.hostName = "nicknix";

  hardware = {
    pulseaudio = {
      enable = true;
        support32Bit = true;
    };
  };

  environment.systemPackages = with pkgs; [
    abcde
  ] ++ basePackages;

  services = lib.recursiveUpdate baseServices {
    xserver = {
      videoDrivers = [ "nvidia" ];
      displayManager.slim = {
        theme = pkgs.fetchurl {
          url    = "https://github.com/nickjanus/nixos-slim-theme/archive/2.1.tar.gz";
          sha256 = "8b587bd6a3621b0f0bc2d653be4e2c1947ac2d64443935af32384bf1312841d7";
        };
      };
    };
  };
}
