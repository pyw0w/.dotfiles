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
      max-jobs = "auto";
      cores = 0;
      # Оптимизации для ускорения загрузки
      auto-optimise-store = true;
      http-connections = 50;
      builders-use-substitutes = true;
      connect-timeout = 60;
      max-silent-time = 3600;
      build-timeout = 3600;
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

  # Автоматическая очистка старых поколений
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Ограничение количества поколений
  boot.loader.systemd-boot.configurationLimit = 3;

  # Системные оптимизации для производительности
  boot.kernel.sysctl = {
    # Оптимизации сети
    "net.core.rmem_max" = 134217728;
    "net.core.wmem_max" = 134217728;
    "net.ipv4.tcp_rmem" = "4096 87380 134217728";
    "net.ipv4.tcp_wmem" = "4096 65536 134217728";
    # Оптимизации файловой системы
    "vm.swappiness" = 10;
    "vm.dirty_ratio" = 15;
    "vm.dirty_background_ratio" = 5;
    # Оптимизации для параллельной работы
    "kernel.sched_autogroup_enabled" = 0;
  };

  # Оптимизации для быстрой загрузки
  systemd.services.nix-daemon = {
    environment = {
      NIX_BUILD_CORES = "0";
      NIX_REMOTE = "daemon";
      # Переменные для подробного вывода
     
    };
  };

  system.stateVersion = "25.05";
}
