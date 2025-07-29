{
  description = "template for hydenix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hydenix.url = "github:richen604/hydenix";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    yandex-music.url = "github:cucumber-sp/yandex-music-linux";
  };

  outputs = { hydenix, yandex-music, ... }@inputs:
    let
      hostname = "nix";
      system = hydenix.lib.system;
      hydenixConfig = hydenix.inputs.hydenix-nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [ ./configuration.nix ];
      };
    in {
      nixosConfigurations = {
        nixos = hydenixConfig;
        ${hostname} = hydenixConfig;
      };
    };
}
