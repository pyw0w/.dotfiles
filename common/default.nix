{
  inputs,
  hostname,
  pkgs,
  ...
}:
{
  imports = [
    ./nix
    ./networking
    ./hardware
    ./security
    ./system
  ];
}
