# This file is symlinked to ../machine.nix on my desktop

{ lib, pkgs, default_services, base_packages }:

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

  environment.systemPackages = with pkgs; [
  ] ++ base_packages;

  services = lib.recursiveUpdate default_services {
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
