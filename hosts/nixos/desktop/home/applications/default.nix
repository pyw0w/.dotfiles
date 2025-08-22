{
  pkgs,
  ...
}:
{
  # User settings
  home = {
    username = "pyw0w";
    homeDirectory = "/home/pyw0w";
    stateVersion = "23.11"; # do not change
  };

  # GTK configuration
  gtk = {
    enable = true;
    iconTheme = {
      name = "rose-pine-moon";
      package = pkgs.rose-pine-icon-theme;
    };
  };

  # Terminal applications
  programs = {
    foot = {
      enable = true;
      settings = {
        main.pad = "8x8 center-when-fullscreen";
      };
    };

    kitty = {
      enable = true;
      font.size = 12;
      extraConfig = ''
        draw_minimal_borders yes
        resize_in_steps no
        dynamic_background_opacity yes

        map ctrl+shift+0 set_background_opacity +0.1
        map ctrl+shift+9 set_background_opacity -0.1

        symbol_map U+E0A0-U+E0A3,U+E0C0-U+E0C7 PowerlineSymbols
        symbol_map U+f000-U+f2e0 Font Awesome 6 Free
      '';
    };

    # Security
    swaylock.enable = true;

    # Launcher
    fuzzel.enable = true;

    # Media player
    mpv = {
      enable = true;
      bindings = {
        G = "osd-msg-bar seek 100 absolute-percent+exact";

        RIGHT = "seek  5 exact"; # forward
        LEFT = "seek -5 exact"; # backward
        WHEEL_UP = "seek  5 exact"; # forward
        WHEEL_DOWN = "seek -5 exact"; # backward

        UP = "seek  30 exact"; # forward
        DOWN = "seek -30 exact"; # backward

        "Alt+=" = "add video-zoom 0.1";
      };
      config = {
        vo = "gpu-next";
        hwdec = "auto-copy";
        hwdec-codecs = "all";
        profile = "gpu-hq";
        dscale = "catmull_rom";
        ao = "pipewire";

        screenshot-format = "png";
        screenshot-directory = "~/Pictures";
        screenshot-tag-colorspace = "no";
        screenshot-high-bit-depth = "no";
        screenshot-png-compression = 6;
        screenshot-png-filter = 0;

        keep-open = "yes";
        force-window = "yes";
        osd-bar-w = 40;
        osd-bar-h = 2;
        volume-max = 200;
        cursor-autohide = 100;
        sub-border-size = 2;
      };
      profiles = {
        stream = {
          demuxer-lavf-o-add = "fflags=+nobuffer+fastseek+flush_packets";
          demuxer-lavf-probe-info = "auto";
          demuxer-lavf-analyzeduration = 0.1;
          demuxer-max-bytes = "128M";
          demuxer-max-back-bytes = "128M";
          gapless-audio = "yes";
          prefetch-playlist = "yes";
          cache-pause = "no";
          untimed = "yes";
          video-sync = "audio";
          force-seekable = "yes";
          hr-seek = "yes";
          hr-seek-framedrop = "yes";
          interpolation = "no";
          video-latency-hacks = "yes";
        };
      };
    };

    # Text editor
    helix = {
      enable = true;
      settings = {
        editor = {
          line-number = "relative";
          lsp.display-messages = true;
        };
        keys.normal = {
          space.space = "file_picker";
          esc = [
            "collapse_selection"
            "keep_primary_selection"
          ];
        };
      };
    };
  };

  # Services
  services = {
    mpris-proxy.enable = true;

    swaync = {
      enable = true;
      settings = {
        control-center-margin-top = 4;
        control-center-margin-right = 4;
        control-center-margin-bottom = 4;
        notification-window-width = 400;
        widgets = [
          "mpris"
          "inhibitors"
          "notifications"
        ];
      };
      style = ''
        .control-center {
          background: alpha(@base00, 0.8);
          border: 2px solid @base0D;
          border-radius: 12px;
        }

        .control-center .notification-row .notification-background {
          background: transparent;
        }

        .notification {
          border-radius: 12px;
          margin: 0;
        }

        .widget-mpris .widget-mpris-player > box > button {
          border: none;
        }

        .widget-mpris .widget-mpris-player > box > button:hover {
          border: none;
        }
      '';
    };
  };
} 