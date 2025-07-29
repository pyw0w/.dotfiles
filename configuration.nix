{ inputs, ... }:
let
  pkgs = import inputs.hydenix.inputs.hydenix-nixpkgs {
    inherit (inputs.hydenix.lib) system;
    config.allowUnfree = true;
    overlays = [
      inputs.hydenix.lib.overlays
      (final: prev: {
        userPkgs = import inputs.nixpkgs { config.allowUnfree = true; };
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
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "mirror.sjtu.edu.cn-nix-channels:APySiQHDIQyE7Po8ev3xsodtNc2X11qo6idbwMl3HFA="
        "mirror.iscas.ac.cn-nix-channels:APySiQHDIQyE7Po8ev3xsodtNc2X11qo6idbwMl3HFA="
        "mirrors.tuna.tsinghua.edu.cn-nix-channels:APySiQHDIQyE7Po8ev3xsodtNc2X11qo6idbwMl3HFA="
      ];
      max-jobs = "auto";
      cores = 0;
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
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs.inputs = inputs;
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

  system.stateVersion = "25.05";
}
