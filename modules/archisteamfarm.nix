args@{ lib, pkgs, variables, device, config, ... }:

{
  options.local.archisteamfarm.enable = lib.mkEnableOption "whether to enable ArchiSteamFarm";

  config = lib.mkIf config.local.archisteamfarm.enable {
    environment.systemPackages = with pkgs; [
      local.archisteamfarm
    ];

    # Create a systemd service for ArchiSteamFarm
    systemd.services.asf = {
      description = "ArchiSteamFarm - Steam Card Farmer";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      
      serviceConfig = {
        Type = "simple";
        User = variables.username;
        Group = variables.username;
        WorkingDirectory = "/home/${variables.username}/.config/archisteamfarm";
        ExecStart = "${pkgs.local.archisteamfarm}/bin/ArchiSteamFarm";
        Restart = "on-failure";
        RestartSec = 10;
        
        # Environment variables to control ASF behavior
        Environment = [
          "ASF_PATH=/home/${variables.username}/.config/archisteamfarm"
          "ASF_CONFIG_PATH=/home/${variables.username}/.config/archisteamfarm/config"
          "ASF_LOG_PATH=/home/${variables.username}/.config/archisteamfarm/logs"
          "ASF_PLUGINS_PATH=/home/${variables.username}/.config/archisteamfarm/plugins"
        ];
        
        # Less restrictive security settings to allow file access
        NoNewPrivileges = true;
        PrivateTmp = false;
        ProtectSystem = false;
        ProtectHome = false;
        ReadWritePaths = [
          "/home/${variables.username}/.config/archisteamfarm"
          "/home/${variables.username}/.local/share/archisteamfarm"
          "/tmp"
        ];
      };
    };

    # Create user directory for ASF configuration
    systemd.tmpfiles.rules = [
      "d /home/${variables.username}/.config/archisteamfarm 0755 ${variables.username} ${variables.username} -"
      "d /home/${variables.username}/.config/archisteamfarm/config 0755 ${variables.username} ${variables.username} -"
      "d /home/${variables.username}/.config/archisteamfarm/logs 0755 ${variables.username} ${variables.username} -"
      "d /home/${variables.username}/.config/archisteamfarm/plugins 0755 ${variables.username} ${variables.username} -"
      "d /home/${variables.username}/.local/share/archisteamfarm 0755 ${variables.username} ${variables.username} -"
    ];
  };
}
