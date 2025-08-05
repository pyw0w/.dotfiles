{ inputs, lib, ... }:
let
  pkgs = import inputs.hydenix.inputs.hydenix-nixpkgs {
    inherit (inputs.hydenix.lib) system;
    config.allowUnfree = true;
    overlays = [
      inputs.hydenix.lib.overlays
      (final: prev: {
        userPkgs = import inputs.nixpkgs { config.allowUnfree = true; };
        # Override Cursor with version from nixpkgs unstable
        code-cursor = (import inputs.nixpkgs-unstable {
          system = inputs.hydenix.lib.system;
          config.allowUnfree = true;
        }).code-cursor;
      })
    ];
  };
in {
  nixpkgs.pkgs = pkgs;

  nix = {
    settings = {
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://mirror.sjtu.edu.cn/nix-channels/store"
        "https://mirror.iscas.ac.cn/nix-channels/store"
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
        # Дополнительные быстрые кэши
        "https://hyprland.cachix.org"
        "https://nixpkgs-wayland.cachix.org"
        "https://nix-gaming.cachix.org"
        "https://cache.ngi0.nixos.org"
        "https://nixpkgs-update.cachix.org"
        "https://nix-community.cachix.org"
        "https://ryantm.cachix.org"
        "https://mic92.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "mirror.sjtu.edu.cn-nix-channels:APySiQHDIQyE7Po8ev3xsodtNc2X11qo6idbwMl3HFA="
        "mirror.iscas.ac.cn-nix-channels:APySiQHDIQyE7Po8ev3xsodtNc2X11qo6idbwMl3HFA="
        "mirrors.tuna.tsinghua.edu.cn-nix-channels:APySiQHDIQyE7Po8ev3xsodtNc2X11qo6idbwMl3HFA="
        # Ключи для дополнительных кэшей
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sBXho9Q9CQJw="
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/t3UxaeYCS59qIYjAki4OaIYqY="
        "cache.ngi0.nixos.org-1:4sA9nXFtyFfaN1CJipan9h9Q5isF+E8yu/1e7jLhQGU="
        "nixpkgs-update.cachix.org-1:6y6Z2JdoL3APdu6Xo8dY1x9L7TNwuZ7e3fq9Xt+vMdmE="
        "ryantm.cachix.org-1:EkFaS4psu2VmLy+JtM1BzSbb6aLVT1M991RF9Yf0Of8="
        "mic92.cachix.org-1:j8v0ATB19XkmUdb3hRYfYM3eVlk10G6d81jCvyp10Gg="
      ];
      max-jobs = 12;  # 12 параллельных сборок (оптимально для 6 ядер, 12 потоков)
      cores = 12;     # Используем все 12 потоков
      # Агрессивные оптимизации для ускорения загрузки
      auto-optimise-store = true;
      http-connections = 100;  # Увеличиваем соединения
      builders-use-substitutes = true;
      connect-timeout = 30;    # Уменьшаем таймауты
      max-silent-time = 1800;  # Уменьшаем время ожидания
      build-timeout = 1800;    # Уменьшаем время сборки
      # Дополнительные оптимизации для скорости
      keep-going = true;       # Продолжать при ошибках
      fallback = true;         # Fallback на сборку
      show-trace = false;      # Отключаем трассировку
      # Дополнительные оптимизации
      experimental-features = [ "nix-command" "flakes" "ca-derivations" "recursive-nix" ];
      # Увеличиваем буферы для быстрой загрузки
      narinfo-cache-negative-ttl = 1;
      narinfo-cache-positive-ttl = 3600;
      # Оптимизации для параллельной работы
      gc-keep-derivations = true;
      gc-keep-outputs = true;
      # Увеличиваем лимиты для больших пакетов
      max-free = 1073741824; # 1GB
      min-free = 1073741824; # 1GB
      # Оптимизации для сети
      tarball-ttl = 3600;
      # Включаем новые функции
      accept-flake-config = true;
      warn-dirty = false;
    };
  };

  imports = [
    inputs.hydenix.inputs.home-manager.nixosModules.home-manager
    ./hardware-configuration.nix
    inputs.hydenix.lib.nixOsModules
    ./modules/system
    # GPU/CPU/hardware modules (uncomment as needed)
    #inputs.hydenix.inputs.nixos-hardware.nixosModules.common-gpu-nvidia
    #inputs.hydenix.inputs.nixos-hardware.nixosModules.common-gpu-amd
    #inputs.hydenix.inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.hydenix.inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.hydenix.inputs.nixos-hardware.nixosModules.common-pc
    inputs.hydenix.inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];

  home-manager = {
    useGlobalPkgs = false;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { 
      inherit inputs;
      pkgs = pkgs;
      unstable = (import inputs.nixpkgs {
        system = inputs.hydenix.lib.system;
        config.allowUnfree = true;
      });
    };
    users."pyw0w" = { ... }: {
      imports = [
        inputs.hydenix.lib.homeModules
        inputs.nix-index-database.homeModules.nix-index
        ./modules/hm
      ];
    };
  };

  hydenix = {
    enable = true;
    hostname = "nix";
    timezone = "Asia/Yekaterinburg";
    locale = "ru_RU.UTF-8";
  };

  users.users.pyw0w = {
    isNormalUser = true;
    initialPassword = "petr4381";
    extraGroups = [ "wheel" "networkmanager" "video" ];
    shell = pkgs.zsh;
  };

  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      extraArgs = "--keep-since 4d --keep 3";
    };
    flake = "/home/pyw0w/.dotfiles";
  };

  # Автоматическая очистка старых поколений (отключена в пользу nh)
  # nix.gc = {
  #   automatic = true;
  #   dates = "weekly";
  #   options = "--delete-older-than 7d";
  # };

  # Ограничение количества поколений
  boot.loader.systemd-boot.configurationLimit = 3;

  # Fix Polkit issues
  security.polkit.enable = true;
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (subject.isInGroup("wheel")) {
        polkit.log("wheel group access granted");
        return polkit.Result.YES;
      }
    });
  '';

  # Агрессивные системные оптимизации для производительности (64GB RAM, 6 ядер, 12 потоков)
  boot.kernel.sysctl = {
    # Агрессивные оптимизации сети для быстрой загрузки
    "net.core.rmem_max" = 536870912;  # 512MB
    "net.core.wmem_max" = 536870912;  # 512MB
    "net.ipv4.tcp_rmem" = "8192 262144 536870912";
    "net.ipv4.tcp_wmem" = "8192 262144 536870912";
    "net.core.netdev_max_backlog" = 5000;
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.ipv4.tcp_fastopen" = 3;
    # Агрессивные оптимизации файловой системы для мощного железа
    "vm.swappiness" = 0;              # Отключаем swap
    "vm.dirty_ratio" = 30;            # Ещё больше кэша
    "vm.dirty_background_ratio" = 15; # Ещё больше фоновой записи
    # Агрессивные оптимизации для параллельной работы
    "kernel.sched_autogroup_enabled" = 0;
    "kernel.sched_min_granularity_ns" = 1000000;
    "kernel.sched_wakeup_granularity_ns" = 1000000;
    # Агрессивные оптимизации памяти
    "vm.vfs_cache_pressure" = 25;     # Ещё меньше давления на кэш
    "vm.dirty_writeback_centisecs" = 250; # Ещё чаще запись
    "vm.overcommit_memory" = 1;       # Разрешаем overcommit
    "vm.overcommit_ratio" = 100;      # 100% overcommit
    # Агрессивные оптимизации для сборки
    "fs.file-max" = 4194304;          # Ещё больше открытых файлов
    "fs.inotify.max_user_watches" = 1048576; # Ещё больше watchers
    "fs.inotify.max_user_instances" = 524288;
    "fs.inotify.max_queued_events" = 524288;
    # Оптимизации для CPU
    "kernel.numa_balancing" = 0;      # Отключаем NUMA balancing
    "kernel.sched_rt_runtime_us" = -1; # Неограниченное RT время
  };

  # Агрессивные оптимизации для быстрой загрузки (64GB RAM, 6 ядер, 12 потоков)
  systemd.services.nix-daemon = {
    environment = {
      NIX_BUILD_CORES = "12";  # Используем все 12 потоков
      NIX_REMOTE = "daemon";
      # Отключаем подробный вывод для скорости
      NIX_DEBUG = "0";
      NIX_SHOW_STATS = "0";
      # Агрессивные оптимизации для мощного железа
      NIX_BUILD_MAX_JOBS = "12";
      # Увеличиваем буферы для быстрой сборки
      NIX_BUFFER_SIZE = "2097152";  # 2MB буфер
      # Дополнительные оптимизации
      NIX_DAEMON_SOCKET_PATH = "/nix/var/nix/daemon-socket/socket";
      NIX_DAEMON_LOG_FILE = "/var/log/nix-daemon.log";
    };
    serviceConfig = {
      # Щедрые лимиты памяти для мощного железа
      MemoryMax = "40G";      # До 40GB для nix-daemon
      MemoryHigh = "32G";     # Предупреждение при 32GB
      # Максимальный приоритет для быстрой работы
      Nice = -20;
      # Дополнительные оптимизации
      Restart = "always";
      RestartSec = 1;
      # Увеличиваем лимиты файлов (используем значение по умолчанию NixOS)
      # LimitNOFILE уже установлен в 1048576 системой
    };
  };

  # Fix systemd issues (nvidia-persistenced is handled by hardware.nvidia)

  system.stateVersion = "25.05";
}
