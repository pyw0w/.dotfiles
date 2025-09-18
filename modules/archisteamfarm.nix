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
        
        # Security settings
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = "read-only";
        ReadWritePaths = "/home/${variables.username}/.config/archisteamfarm";
      };
    };

    # Create user directory for ASF configuration
    systemd.tmpfiles.rules = [
      "d /home/${variables.username}/.config/archisteamfarm 0755 ${variables.username} ${variables.username} -"
      "d /home/${variables.username}/.config/archisteamfarm/config 0755 ${variables.username} ${variables.username} -"
      "d /home/${variables.username}/.config/archisteamfarm/logs 0755 ${variables.username} ${variables.username} -"
      "d /home/${variables.username}/.config/archisteamfarm/plugins 0755 ${variables.username} ${variables.username} -"
    ];
  };
}
