# ZED IDE
args@{ config, lib, pkgs, variables, ... }:

lib.mkModule "zed" config {
  environment.systemPackages = with pkgs; [
    zed-editor
  ];
}
