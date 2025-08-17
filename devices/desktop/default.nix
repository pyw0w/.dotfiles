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

  # more swap, couldnt figure out how to change it using disko/btrfs
  swapDevices = [{
    device = "/.swapfile2";
    size = 16*1024; # 16 GB
  }];

  # for focusrite usb audio interface (get with `dmesg | grep Focusrite`)
  boot.extraModprobeConfig = "options snd_usb_audio vid=0x1235 pid=0x8211 device_setup=1";

  environment.systemPackages = with pkgs; [
    # alsa-scarlett-gui # control center for focusrite usb audio interface
    # liquidctl # liquid cooler control (removed - no hardware)
    # to mount encrypted data partition
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

  # Russian language support (basic configuration)
  # Uncomment the following for full input method support:
  # i18n.inputMethod = {
  #   type = "fcitx5";
  #   enable = true;
  #   fcitx5.addons = with pkgs; [
  #     fcitx5-gtk
  #     fcitx5-configtool
  #     pkgs.libsForQt5.fcitx5-qt
  #     fcitx5-mozc
  #     fcitx5-hangul
  #     fcitx5-chinese-addons
  #   ];
  # };

  # Console keyboard layout
  console.keyMap = "us";
  
  # liquidctl service removed - no liquid cooler currently connected
  # Uncomment and modify the following if you add a liquid cooler:
  # systemd.services.liquidctl = {
  #   enable = true;
  #   description = "set liquid cooler pump speed curve";
  #   serviceConfig = {
  #     User = "root";
  #     Type = "oneshot";
  #     RemainAfterExit = "yes";
  #     ExecStart = [
  #       "${pkgs.liquidctl}/bin/liquidctl initialize all"
  #       "${pkgs.liquidctl}/bin/liquidctl --match kraken set pump speed 30 55 40 100"
  #     ];
  #   };
  #   wantedBy = [ "default.target" ];
  # };
  
  # openrgb
  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
  };
  systemd.services.openrgb-sleep-wrapper = {
    enable = true;
    description = "turn off rgb before entering sleep and turn it back on when waking up";
    unitConfig = {
      Before = "sleep.target";
      StopWhenUnneeded = "yes";
    };
    serviceConfig = {
      User = variables.username;
      Type = "oneshot";
      RemainAfterExit = "yes";
      ExecStart = "-${pkgs.openrgb}/bin/openrgb -p off";
      ExecStop  = "-${pkgs.openrgb}/bin/openrgb -p default";
    };
    wantedBy = [ "sleep.target" ];
  };
}