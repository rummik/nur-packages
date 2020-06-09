{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.pia;
  pkg = pkgs.nur.repos.rummik.pia-daemon;

in

{
  options = {
    services.pia = {
      enable = mkEnableOption "Enable Private Internet Access VPN daemon";
    };
  };

  config = mkIf cfg.enable {
    users.extraGroups.piavpn.gid = null;

    services.resolved.enable = mkDefault true;

    systemd.services.pia = {
      description = "Private Internet Access daemon";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "syslog.target" "network.target" "network-online.target" ];

      path = with pkgs; [
        inetutils
        networkmanager
        openvpn
        wireguard
        zip
      ];

      preStart = /* sh */ ''
        mkdir -p /opt/piavpn/{bin,etc,var}
        cp -rf ${pkg}/{bin,etc} /opt/piavpn/
      '';

      environment = {
        LD_LIBRARY_PATH = "${pkg}/lib";
      };

      serviceConfig = {
        Restart = "always";
        ExecStart = "/opt/piavpn/bin/pia-daemon";
      };
    };
  };
}

