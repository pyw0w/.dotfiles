# Cursor IDE
args@{ config, lib, pkgs, variables, ... }:

lib.mkModule "cursor" config {
  environment.systemPackages = with pkgs; [
    code-cursor
  ];
}
