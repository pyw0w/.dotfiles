{ pkgs, lib, ... }:

{
  # Russian language support
  i18n = {
    defaultLocale = lib.mkDefault "en_US.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "ru_RU.UTF-8/UTF-8"
    ];
    inputMethod = {
      type = "ibus";
      enable = true;
      ibus.engines = with pkgs.ibus-engines; [
        m17n
      ];
    };
  };

  # Font configuration for Cyrillic support
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      mplus-outline-fonts.githubRelease
      dina-font
      proggyfonts
    ];
    fontconfig = {
      defaultFonts = {
        monospace = [ "Fira Code" "Noto Sans Mono" ];
        sansSerif = [ "Noto Sans" "Liberation Sans" ];
        serif = [ "Noto Serif" "Liberation Serif" ];
      };
    };
  };

  # Environment variables for better Russian support
  environment.variables = {
    GTK_IM_MODULE = "ibus";
    QT_IM_MODULE = "ibus";
    XMODIFIERS = "@im=ibus";
  };

  # Keyboard layout configuration
  services.xserver.xkb = {
    layout = "us,ru";
    options = "grp:alt_shift_toggle,grp_led:scroll";
  };
} 