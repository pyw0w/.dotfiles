{
  inputs = {                 
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";
    home-manager = { url = "github:nix-community/home-manager?ref=release-25.05";
      inputs.nixpkgs.follows = "nixpkgs"; };
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    couchdb-aarch64-nixpkgs.url = "github:nixos/nixpkgs?rev=eb0e0f21f15c559d2ac7633dc81d079d1caf5f5f";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1&ref=refs/tags/v0.50.1";
    hyprsplit = { url = "github:shezdy/hyprsplit?ref=v0.50.1";
      inputs.hyprland.follows = "hyprland"; };
    nur = { url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs"; };
    disko = { url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs"; };
    programs-sqlite = { url = "github:wamserma/flake-programs-sqlite";
      inputs.nixpkgs.follows = "nixpkgs-unstable"; };
    # declarative discord config
    nixcord = { url = "github:kaylorben/nixcord";
      inputs.nixpkgs.follows = "nixpkgs"; };
    nh = { url = "github:nix-community/nh";
      inputs.nixpkgs.follows = "nixpkgs"; };
    zenix = { url = "github:anders130/zenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager"; };
    ashell = { url = "github:MalpenZibo/ashell";
      inputs.nixpkgs.follows = "nixpkgs"; };
  };
  outputs = inputs@{ self, ... }:
  let
    variables = import ./variables.nix;
    mkNixosConfig = device@{
      internalName,
      system ? "x86_64-linux",
      hostName ? "nixos",
    }:
    let
      pkgs-config = {
        inherit system;
        config.allowUnfree = true; 
        # for open-webui on aarch64 https://github.com/NixOS/nixpkgs/issues/312068#issuecomment-2365236799
        overlays = [( _: prev: { pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [( _: python-prev: {
          rapidocr-onnxruntime = python-prev.rapidocr-onnxruntime.overridePythonAttrs (self: {
            pythonImportsCheck = if python-prev.stdenv.isAarch64 then [] else ["rapidocr_onnxruntime"];
            doCheck = !(python-prev.stdenv.isAarch64);
            meta = self.meta // { badPlatforms = []; };
          });
          chromadb = python-prev.chromadb.overridePythonAttrs (self: {
            pythonImportsCheck = if python-prev.stdenv.isAarch64 then [] else ["chromadb"];
            doCheck = !(python-prev.stdenv.isAarch64);
            meta = self.meta // { broken = false; };
          });
        })]; })];
      };
      pkgs          = import inputs.nixpkgs          pkgs-config;
      pkgs-unstable = import inputs.nixpkgs-unstable pkgs-config;
      pkgs-local    = import ./packages { inherit pkgs; };
      lib = inputs.nixpkgs.lib.extend (final: prev: inputs.home-manager.lib // {
        getNixpkgs  = input: import inputs.${input} pkgs-config;
        getPkgs     = input: inputs.${input}.packages.${system};
        writeScript     = pkgs.writeShellScriptBin;
        writeScriptFile = name: path: pkgs.writeShellScriptBin name (builtins.readFile(path));
        importIfExists  = path: if builtins.pathExists path then import path else {};
        mkModule = name: currentConfig: newConfig: {
          options.local.${name}.enable = lib.mkEnableOption "whether to enable ${name}";
          config = lib.mkIf currentConfig.local.${name}.enable newConfig;
        };
      });
      specialArgs = {
        inherit inputs variables lib;
        device = { inherit system hostName; } // device;
      };
    in
    lib.nixosSystem {
      inherit system specialArgs;
      modules = [
        ./modules
        ./devices/${internalName} 
        (lib.importIfExists ./devices/${internalName}/hardware-configuration.nix)
        (lib.importIfExists ./devices/${internalName}/disk-config.nix)
        inputs.disko.nixosModules.disko # disk management
        inputs.nur.modules.nixos.default # NUR package overlay
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.extraSpecialArgs = specialArgs;
          nixpkgs.overlays = [
            (final: prev: {
              /*pkgs.*/unstable = pkgs-unstable;
              /*pkgs.*/local    = pkgs-local;
            })
            (if builtins.pathExists ./devices/${internalName}/overlays.nix
              then import ./devices/${internalName}/overlays.nix specialArgs
              else _: _: {})
            inputs.zenix.overlays.default
          ];
        }
      ];
    };
    mkNixosConfigs = nixosConfigs: 
      builtins.mapAttrs (ignored: namedConfig: mkNixosConfig namedConfig) (
        builtins.listToAttrs (
          builtins.map (config: {
            value = config;
            name = config.internalName; 
          }) nixosConfigs
        )
      );
  in
  let
    nixosConfigs = variables.nixosConfigs { inherit mkNixosConfigs inputs; };
  in
  {
    nixosConfigurations = nixosConfigs;
    desktop = nixosConfigs.desktop;
    laptop = nixosConfigs.laptop;
  };
}
