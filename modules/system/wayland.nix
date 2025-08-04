{ config, pkgs, ... }:

{
  # Wayland configuration
  environment.variables = {
    # Disable screen blanking
    WLR_NO_HARDWARE_CURSORS = "1";
    # Disable automatic screen blanking
    WLR_DRM_NO_ATOMIC = "1";
    # NVIDIA specific variables for Wayland
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    # Hyprland specific variables
    XDG_SESSION_TYPE = "wayland";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    GDK_BACKEND = "wayland";
    CLUTTER_BACKEND = "wayland";
    SDL_VIDEODRIVER = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1";
  };

  # Hyprland configuration
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # XDG portal configuration for Wayland
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    config.common.default = "hyprland";
  };

  # Disable automatic screen blanking via systemd
  systemd.user.services = {
    # Disable automatic screen blanking
    "org.freedesktop.ScreenSaver" = {
      enable = false;
    };
  };

  # Additional power management settings
  services.upower = {
    enable = true;
    percentageLow = 10;
    percentageCritical = 5;
    percentageAction = 2;
    criticalPowerAction = "Hibernate";
  };

  # Disable automatic screen blanking in console
  console.useXkbConfig = true;

  # Additional system packages for Wayland/Hyprland
  environment.systemPackages = with pkgs; [
    # Wayland utilities
    wl-clipboard
    grim
    slurp
    wf-recorder
    # Hyprland utilities
    hyprpaper
    hyprpicker
    # Additional tools
    waybar
    dunst
    rofi-wayland
  ];
} 