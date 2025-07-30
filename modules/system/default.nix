{ pkgs, ... }:

{
  imports = [
    ./graphics.nix
    ./russian.nix
    ./power.nix
    ./wayland.nix
  ];

  environment.systemPackages = [
  ];
}
