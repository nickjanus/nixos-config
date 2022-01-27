{ config, lib, pkgs, ... }:

with lib;

{
  options.programs.digitalocean-dynamic-dns-ip = {
    enable = mkEnableOption "digitalocean-dynamic-dns-ip";

    conf = mkOption {
      type = types.str;
      default = "";
      description = ''
        JSON config declaring DNS records
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ digitalocean-dynamic-dns-ip ];
    systemd = {
      timers.digitalocean-dynamic-dns-ip-timer = {
        wantedBy = [ "timers.target" ];
        partOf = [ "digitalocean-dynamic-dns-ip-timer.service" ];
        timerConfig.OnCalendar = "minutely";
      };
      services.digitalocean-dynamic-dns-ip-timer = {
        serviceConfig.Type = "oneshot";
        script = ''
          ${digitalocean-dynamic-dns-ip}/bin/digitalocean-dynamic-ip ${pkgs.writeText(cfg.conf)}
        '';
      };
    };
  };
}
