{ lib, config, pkgs, baseServices, basePackages}:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices = {
    nixos = {
      device = "/dev/VolGroup/nixos";
      preLVM = false;
    };
  };

  networking = {
    hostName = "nicknix";
    wireless.enable = true;
  };


  hardware = {
    pulseaudio = {
      enable = true;
        support32Bit = true;
    };
  };
  services = lib.recursiveUpdate baseServices {
    xserver = {
      videoDrivers = [
      "amdgpu"
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    abcde
    cargo
    discord
    gcc
    rustc
  ] ++ basePackages;

}
