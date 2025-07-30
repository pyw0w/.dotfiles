{ config, pkgs, ... }:

{
  # Disable automatic screen blanking
  services.xserver.displayManager.defaultSession = "hyprland";
  
  # Power management settings
  services.logind = {
    lidSwitch = "ignore";
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "ignore";
  };

  # Disable automatic suspend
  powerManagement = {
    enable = true;
    powertop.enable = false;
    cpuFreqGovernor = "performance";
  };

  # Systemd services for power management
  systemd.services = {
    # Disable automatic suspend
    "systemd-suspend" = {
      enable = false;
    };
    
    # Disable automatic hibernate
    "systemd-hibernate" = {
      enable = false;
    };
  };

  # Environment variables for power management
  environment.variables = {
    # Disable screen blanking in X11
    XDG_SESSION_TYPE = "wayland";
    # Disable automatic screen blanking
    XDG_CURRENT_DESKTOP = "Hyprland";
  };
} 