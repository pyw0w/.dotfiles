# modules/7d2d.nix
{ config, lib, pkgs, variables, ... }:

lib.mkModule "7d2d" config {
  systemd.services.sevendaystodie = {
    description = "7 Days to Die Dedicated Server";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      User = variables.username;
      Group = variables.username;
      WorkingDirectory = "/opt/7d2d-server";
      ExecStart = "/opt/7d2d-server/startserver.sh -configfile=serverconfig.xml -logfile /opt/7d2d-server/dedicated.log";
      Restart = "always";
      RestartSec = 10;
      StandardOutput = "journal";
      StandardError = "journal";
      # Дополнительные настройки для игрового сервера
      Nice = -5;  # Повышенный приоритет
      LimitNOFILE = 65536;  # Больше файловых дескрипторов
      PrivateTmp = false;  # Разрешить доступ к временным файлам
    };
  };
}
