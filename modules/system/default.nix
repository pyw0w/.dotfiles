{ pkgs, ... }:

{
  imports = [
    ./graphics.nix
    ./russian.nix
    ./power.nix
    ./wayland.nix
    ./java.nix
  ];

  environment.systemPackages = [
  ];
}
