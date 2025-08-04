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

  # NixOS monitoring scripts
  home.file.".local/bin/nix-status" = {
    text = ''
      #!/bin/bash
      echo "📊 NixOS System Status"
      echo "======================"
      echo "🏗️  System size: $(nix path-info --closure-size /run/current-system | numfmt --to=iec)"
      echo "📅 Generations:"
      sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | tail -5
      echo "💾 Available space: $(df -h /nix | tail -1 | awk '{print $4}')"
      echo "======================"
    '';
    executable = true;
  };

  home.file.".local/bin/nix-clean" = {
    text = ''
      #!/bin/bash
      KEEP="$1"
      if [[ -z "$KEEP" ]]; then
        KEEP=3
      fi
      
      echo "🧹 Cleaning NixOS system..."
      echo "📊 Keeping $KEEP generations"
      echo "💾 Size before: $(nix path-info --closure-size /run/current-system | numfmt --to=iec)"
      
      if nh clean all --keep "$KEEP"; then
        echo "✅ Cleanup completed!"
        echo "💾 Size after: $(nix path-info --closure-size /run/current-system | numfmt --to=iec)"
      else
        echo "❌ Cleanup failed!"
        exit 1
      fi
    '';
    executable = true;
  };

  home.file.".local/bin/nix-switch-fast" = {
    text = ''
      #!/bin/bash
      echo "🚀 Starting system switch..."
      echo "📊 Start time: $(date)"
      
      if nh os switch; then
        echo "✅ Switch completed successfully!"
        echo "📊 End time: $(date)"
        echo "💾 System size: $(nix path-info --closure-size /run/current-system | numfmt --to=iec)"
      else
        echo "❌ Switch failed!"
        exit 1
      fi
    '';
    executable = true;
  };
} 