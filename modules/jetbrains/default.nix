# jetbrains ide's
args@{ config, lib, pkgs, variables, ... }:
lib.mkModule "jetbrains" config {
  environment.systemPackages = with pkgs.jetbrains; [
    pycharm-community
    #idea-community
    #rust-rover
    #rider
  ];

  # IdeaVim configuration removed - using default editor behavior
}