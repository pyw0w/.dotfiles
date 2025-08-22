{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.niri = {
    settings = {
      prefer-no-csd = true;
      clipboard.disable-primary = true;
      hotkey-overlay.skip-at-startup = true;
      gestures.hot-corners.enable = false;

      layout = {
        gaps = 4;
        border.width = 2;
        tab-indicator.place-within-column = true;
      };

      environment.DISPLAY = ":0";

      spawn-at-startup = [
        { command = [ "${lib.getExe pkgs.xwayland-satellite-unstable}" ]; }
        {
          command = [
            "${lib.getExe pkgs.swaybg}"
            "--mode"
            "center"
            "--image"
            (inputs.self + /assets/wallpaper.jpg)
          ];
        }
        {
          command = [
            "${lib.getExe pkgs.swayidle}"
            "timeout"
            "15"
            "pgrep swaylock && niri msg action power-off-monitors"
            "resume"
            "niri msg action power-on-monitors"
          ];
        }
        { command = [ "waybar" ]; }
      ];

      window-rules = [
        {
          clip-to-geometry = true;
          geometry-corner-radius = {
            bottom-left = 12.0;
            bottom-right = 12.0;
            top-left = 12.0;
            top-right = 12.0;
          };
          shadow = {
            enable = true;
            softness = 30;
            spread = 5;
            offset = {
              x = 0;
              y = 5;
            };
            color = "#0007";
          };
        }
        {
          matches = [
            { app-id = ''^org\.keepassxc\.KeePassXC$''; }
          ];
          block-out-from = "screen-capture";
        }
      ];

      outputs = {
        "DP-1" = {
          mode = {
            width = 1920;
            height = 1080;
            refresh = 144.001;
          };
          position = {
            x = 1920;
            y = 0;
          };
        };
        "HDMI-A-1" = {
          position = {
            x = 0;
            y = 0;
          };
        };
      };

      input = {
        mod-key = "Win";
        mouse.accel-profile = "flat";
        workspace-auto-back-and-forth = true;
        keyboard.xkb = {
          layout = "us,ru";
          options = "grp:alt_shift_toggle";
        };
      };

      binds = with config.lib.niri.actions; {
        "Mod+Shift+Slash".action = show-hotkey-overlay;

        "Ctrl+Mod+T".action = spawn "foot";
        "Mod+D".action = spawn "fuzzel";
        "Mod+L".action = spawn "swaylock";

        "Mod+Tab".action = toggle-overview;

        "Mod+Shift+Q".action = close-window;

        "Mod+Left".action = focus-column-or-monitor-left;
        "Mod+Down".action = focus-window-down;
        "Mod+Up".action = focus-window-up;
        "Mod+Right".action = focus-column-or-monitor-right;

        "Mod+Shift+Left".action = move-column-left;
        "Mod+Shift+Down".action = move-window-down;
        "Mod+Shift+Up".action = move-window-up;
        "Mod+Shift+Right".action = move-column-right;

        "Mod+Home".action = focus-column-first;
        "Mod+End".action = focus-column-last;
        "Mod+Ctrl+Home".action = move-column-to-first;
        "Mod+Ctrl+End".action = move-column-to-last;

        "Mod+Ctrl+Left".action = focus-monitor-left;
        "Mod+Ctrl+Down".action = focus-monitor-down;
        "Mod+Ctrl+Up".action = focus-monitor-up;
        "Mod+Ctrl+Right".action = focus-monitor-right;

        "Mod+Page_Down".action = focus-workspace-down;
        "Mod+Page_Up".action = focus-workspace-up;
        "Mod+Ctrl+Page_Down".action = move-column-to-workspace-down;
        "Mod+Ctrl+Page_Up".action = move-column-to-workspace-up;

        "Mod+Shift+Page_Down".action = move-workspace-down;
        "Mod+Shift+Page_Up".action = move-workspace-up;

        "Mod+WheelScrollDown" = {
          cooldown-ms = 150;
          action = focus-workspace-down;
        };
        "Mod+WheelScrollUp" = {
          cooldown-ms = 150;
          action = focus-workspace-up;
        };
        "Mod+Ctrl+WheelScrollDown" = {
          cooldown-ms = 150;
          action = move-column-to-workspace-down;
        };
        "Mod+Ctrl+WheelScrollUp" = {
          cooldown-ms = 150;
          action = move-column-to-workspace-up;
        };

        "Mod+WheelScrollRight".action = focus-column-right;
        "Mod+WheelScrollLeft".action = focus-column-left;
        "Mod+Ctrl+WheelScrollRight".action = move-column-right;
        "Mod+Ctrl+WheelScrollLeft".action = move-column-left;

        "Mod+Shift+WheelScrollDown".action = focus-column-right;
        "Mod+Shift+WheelScrollUp".action = focus-column-left;
        "Mod+Ctrl+Shift+WheelScrollDown".action = move-column-right;
        "Mod+Ctrl+Shift+WheelScrollUp".action = move-column-left;

        "Mod+1".action = focus-workspace 1;
        "Mod+2".action = focus-workspace 2;
        "Mod+3".action = focus-workspace 3;
        "Mod+4".action = focus-workspace 4;
        "Mod+5".action = focus-workspace 5;
        "Mod+6".action = focus-workspace 6;
        "Mod+7".action = focus-workspace 7;
        "Mod+8".action = focus-workspace 8;
        "Mod+9".action = focus-workspace 9;

        "Mod+Shift+1".action = {
          move-window-to-workspace = 1;
        };
        "Mod+Shift+2".action = {
          move-window-to-workspace = 2;
        };
        "Mod+Shift+3".action = {
          move-window-to-workspace = 3;
        };
        "Mod+Shift+4".action = {
          move-window-to-workspace = 4;
        };
        "Mod+Shift+5".action = {
          move-window-to-workspace = 5;
        };
        "Mod+Shift+6".action = {
          move-window-to-workspace = 6;
        };
        "Mod+Shift+7".action = {
          move-window-to-workspace = 7;
        };
        "Mod+Shift+8".action = {
          move-window-to-workspace = 8;
        };
        "Mod+Shift+9".action = {
          move-window-to-workspace = 9;
        };

        "Mod+BracketLeft".action = consume-or-expel-window-left;
        "Mod+BracketRight".action = consume-or-expel-window-right;

        "Mod+Comma".action = consume-window-into-column;
        "Mod+Period".action = expel-window-from-column;

        "Mod+R".action = switch-preset-column-width;
        "Mod+Shift+R".action = switch-preset-window-height;
        "Mod+Ctrl+R".action = reset-window-height;
        "Mod+F".action = maximize-column;
        "Mod+Shift+F".action = fullscreen-window;
        "Mod+Ctrl+F".action = expand-column-to-available-width;
        "Mod+C".action = center-column;
        "Mod+Ctrl+C".action = center-visible-columns;

        "Mod+Minus".action = set-column-width "-10%";
        "Mod+Equal".action = set-column-width "+10%";
        "Mod+Shift+Minus".action = set-window-height "-10%";
        "Mod+Shift+Equal".action = set-window-height "+10%";

        "Mod+Shift+Space".action = toggle-window-floating;
        "Mod+Space".action = switch-focus-between-floating-and-tiling;

        "Mod+W".action = toggle-column-tabbed-display;

        "Print".action = screenshot;
        # "Ctrl+Print".action = screenshot-screen;
        "Alt+Print".action = screenshot-window;

        "Mod+Escape" = {
          allow-inhibiting = false;
          action = toggle-keyboard-shortcuts-inhibit;
        };

        "Mod+Shift+E".action = quit;
        "Ctrl+Alt+Delete".action = quit;

        "Mod+Shift+P".action = power-off-monitors;

        "XF86AudioRaiseVolume".action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "4%+";
        "XF86AudioLowerVolume".action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "4%-";
        "XF86AudioMute".action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle";
        "XF86AudioMicMute".action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle";
        "XF86AudioPlay".action = spawn "playerctl" "play-pause";
        "XF86AudioPause".action = spawn "playerctl" "play-pause";
        "XF86AudioNext".action = spawn "playerctl" "next";
        "XF86AudioPrev".action = spawn "playerctl" "previous";
      };
    };
  };
}
