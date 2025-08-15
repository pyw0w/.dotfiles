{
  inputs,
  pkgs,
  ...
}:
{
  nixpkgs = {
    config.allowUnfree = true;

    overlays = (import ./overlays) ++ [
      inputs.nixpkgs-wayland.overlays.default
      inputs.agenix.overlays.default
      inputs.fenix.overlays.default
    ];
  };

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    settings = {
      trusted-users = [
        "root"
        "@wheel"
      ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      warn-dirty = false;
      builders-use-substitutes = true;
      substituters = [
        "https://cache.nixos.org?priority=10"
        "https://nix-community.cachix.org"
        "https://nixpkgs-wayland.cachix.org"
        "https://catppuccin.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
        "catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU="
      ];
    };
  };

  _module.args = with pkgs.stdenv.hostPlatform; {
    unstable = import inputs.nixpkgs-unstable {
      system = pkgs.system;
      config.allowUnfree = true;
    };
  };
}
