{ pkgs, ... }:

{
  imports = [
    ./graphics.nix
    ./russian.nix
  ];

  environment.systemPackages = [
  ];
}
