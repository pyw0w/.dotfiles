# build local packages
{ pkgs, ... }:
{
  sddm-sugar-candy = pkgs.callPackage ./sddm-sugar-candy.nix {};
  develnext = pkgs.callPackage ./develnext.nix {};
  fabric = pkgs.callPackage ./fabric.nix {};
  archisteamfarm = pkgs.callPackage ./archisteamfarm.nix {};
}
