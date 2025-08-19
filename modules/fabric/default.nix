# build custom widgets
args@{ config, lib, pkgs, variables, ... }:
lib.mkModule "fabric" config {
  environment.systemPackages = with pkgs; [
    fabric
  ];

  # symlink config to ~/.config
  home-manager.users.${variables.username} = { config, ... }: {
    xdg.configFile."fabric" = {
      source = config.lib.file.mkOutOfStoreSymlink "/etc/dotfiles/modules/fabric";
      recursive = true;
    };
  };
}