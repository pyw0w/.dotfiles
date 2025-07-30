{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Screen management tools
    brightnessctl
    wlr-randr
  ];

  # Create custom scripts for screen management
  home.file.".local/bin/screen-off" = {
    text = ''
      #!/bin/bash
      # Turn off screen
      hyprctl dispatch dpms off
    '';
    executable = true;
  };

  home.file.".local/bin/screen-on" = {
    text = ''
      #!/bin/bash
      # Turn on screen
      hyprctl dispatch dpms on
    '';
    executable = true;
  };

  home.file.".local/bin/toggle-screen" = {
    text = ''
      #!/bin/bash
      # Toggle screen on/off
      if hyprctl monitors | grep -q "dpmsStatus: 1"; then
        hyprctl dispatch dpms off
      else
        hyprctl dispatch dpms on
      fi
    '';
    executable = true;
  };

  home.file.".local/bin/disable-screen-blanking" = {
    text = ''
      #!/bin/bash
      # Disable screen blanking
      hyprctl dispatch dpms on
      # Set brightness to maximum if brightnessctl is available
      if command -v brightnessctl &> /dev/null; then
        brightnessctl set 100%
      fi
      echo "Screen blanking disabled"
    '';
    executable = true;
  };
} 