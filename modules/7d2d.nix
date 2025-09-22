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

      ExecStart = ''
        /opt/7d2d-server/7DaysToDieServer.x86_64 \
          -logfile /opt/7d2d-server/dedicated.log \
          -configfile=serverconfig.xml \
          -quit -batchmode -nographics \
          -heapsize 16777216
      '';

      Restart = "on-failure";
      RestartSec = 5;

      # Логи в journal + файл
      StandardOutput = "journal";
      StandardError = "journal";

      # Ресурсы и приоритет
      Nice = -5;              # Повышенный приоритет
      LimitNOFILE = 65536;    # Кол-во файловых дескрипторов
      LimitNPROC = 4096;      # Кол-во процессов
      MemoryMax = "20G";
      MemoryHigh = "18G";
      CPUQuota = "0";         # Разрешить все ядра
      IOSchedulingClass = "best-effort";
      IOSchedulingPriority = 2;
      CPUSchedulingPolicy = "other";

      # Для работы Unity/mono
      PrivateTmp = false;
      NoNewPrivileges = true;
    };
  };

  # Директории (если нужно авто-создание)
  systemd.tmpfiles.rules = [
    "d /opt/7d2d-server 0755 ${variables.username} ${variables.username} -"
  ];
}
