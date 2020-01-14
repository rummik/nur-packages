{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.dptf;
  pkg = pkgs.nur.repos.rummik.dptf;

in

{
  options = {
    services.dptf = {
      enable = mkEnableOption "Enable Intel Dynamic Tuning daemon";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.nur.repos.rummik.dptf
    ];

    systemd.services.dptf = {
      description = "Intel Dynamic Tuning daemon";
      wantedBy = [ "sysinit.target" ];

      conflicts = [
        "tlp.service"
        "thermald.service"
        "thinkfan.service"
      ];

      serviceConfig = {
        Type = "forking";
        Restart = "always";
        ExecStart = /* sh */ ''
          ${pkg}/bin/esif_ufd
        '';
      };
    };
  };
}

