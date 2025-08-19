# more gui config i don't want on every device
args@{ config, lib, pkgs, ... }:
{
  options.local.base.gui.full.enable = lib.mkEnableOption "whether to enable full gui config";

  config = lib.mkIf config.local.base.gui.full.enable {

    local = {
      base.gui.enable = true;
      steam.enable = true;
    };

    environment.systemPackages = with pkgs; [
      ### gui
      onlyoffice-bin_latest # office suite
      veracrypt # disk encryption
      freefilesync # file backup
      (prismlauncher.override { jdks = [ jdk17 jdk ]; }) # minecraft
      #bottles # run windows software easily
      #usbimager # create bootable usb stick
      #obs-studio # video recording

      ### cli
      dunst # for better notify-send with dunstify
    ];
  };
}