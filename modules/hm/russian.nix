{ pkgs, ... }:

{
  # Russian language support packages
  home.packages = [
    pkgs.ibus
    pkgs.ibus-engines.m17n
    pkgs.hunspell
    pkgs.hunspellDicts.ru-ru
    pkgs.noto-fonts-cjk-sans
    # For keyboard layout switching
    pkgs.xorg.xkbcomp
    # For notifications
    pkgs.libnotify
    # CUDA development tools
    pkgs.cudaPackages.cudatoolkit
    pkgs.cudaPackages.cudnn
    pkgs.cudaPackages.tensorrt
  ];

  # Environment variables for better Russian support
  home.sessionVariables = {
    GTK_IM_MODULE = "ibus";
    QT_IM_MODULE = "ibus";
    XMODIFIERS = "@im=ibus";
  };

  # IBus configuration
  xdg.configFile."ibus/ibus.conf".text = ''
    [general]
    enable-by-default=true
    embed-preedit-text=true
    use-global-engine=true
    use-system-keyboard-layout=true
  '';

  # GTK input method configuration
  gtk.gtk3.extraConfig = {
    gtk-im-module = "ibus";
  };

  gtk.gtk4.extraConfig = {
    gtk-im-module = "ibus";
  };
} 