{ config, pkgs, ... }:

{
  # Wayland configuration
  environment.variables = {
    # Disable screen blanking
    WLR_NO_HARDWARE_CURSORS = "1";
    # Disable automatic screen blanking
    WLR_DRM_NO_ATOMIC = "1";
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
} 