args@{ pkgs, inputs, device, ... }:
let 
  mesa-pkgs = 
    pkgs;
    #inputs.hyprland.inputs.nixpkgs.legacyPackages.${device.system};
in
{
  imports = [ ../../modules/studies ];

  local = {
    base.gui.full.enable = true;
    base.laptop.enable = true;
  };

  # amd gpu
  hardware.amdgpu.initrd.enable = true;
  hardware.graphics = {
    package   = mesa-pkgs.mesa;
    package32 = mesa-pkgs.pkgsi686Linux.mesa;
  };
}
