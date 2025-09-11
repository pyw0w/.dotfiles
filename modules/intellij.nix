# IntelliJ IDEA Community
args@{ config, lib, pkgs, variables, ... }:

lib.mkModule "intellij" config {
  environment.systemPackages = with pkgs; [
    jetbrains.idea-community
  ];
} 