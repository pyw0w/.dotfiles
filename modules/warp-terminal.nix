# Warp Terminal
args@{ config, lib, pkgs, variables, ... }:
let
  warp-pkgs = pkgs.unstable or pkgs;
in
lib.mkModule "warp-terminal" config {
  environment.systemPackages = with warp-pkgs; [
    warp-terminal
  ];
} 