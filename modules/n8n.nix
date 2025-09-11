# n8n automation tool
args@{ config, lib, pkgs, variables, ... }:

lib.mkModule "n8n" config {
  environment.systemPackages = with pkgs; [
    n8n
  ];

  # ensure data directory exists and is owned by the primary user
  systemd.tmpfiles.rules = [
    "d /data/n8n 0755 ${variables.username} ${variables.username} -"
  ];

  systemd.services.n8n = {
    description = "n8n automation service";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      User = variables.username;
      WorkingDirectory = "/data/n8n";
      ExecStart = "${pkgs.n8n}/bin/n8n start";
      Restart = "always";
      Environment = [
        "N8N_PORT=5678"
        "N8N_HOST=0.0.0.0"
        "N8N_DIAGNOSTICS_ENABLED=false"
      ];
    };
  };
}
