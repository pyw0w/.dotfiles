args@{ config, pkgs, variables, lib, ... }:
{
  imports = [ ../../modules/studies ];

  local = {
    base.gui.full.enable = true;
    nvidia.enable = true;
    piper.enable = true;
    playerctl.enable = true;
    develnext.enable = true;
  };

  environment.systemPackages = with pkgs; [
    zenity # password prompt
    cryptsetup # unlock luks
    dunst # send notifications
    
    # Russian language support
    hunspell
    hunspellDicts.ru-ru
    aspell
    aspellDicts.ru
  ];

  # remove background noise from mic
  programs.noisetorch.enable = true;

  # symlink to home folder
  home-manager.users.${variables.username} = { config, ... }: {
    home.file."Library".source = config.lib.file.mkOutOfStoreSymlink "/mnt/data/Library";
  };
  
  # mouse sens config
  services.libinput.mouse.accelSpeed = "-0.7";

  # Console keyboard layout
  console.keyMap = "us";
}