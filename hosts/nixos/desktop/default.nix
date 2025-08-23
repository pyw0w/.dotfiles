{
  config,
  lib,
  inputs,
  pkgs,
  unstable,
  callPackage,
  ...
}:
{
  imports = [
    ./hardware.nix
    ./packages
    ./services
    ./programs
    inputs.home-manager.nixosModules.default
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "hm-bkp";

        users.pyw0w = {
          _module.args = { inherit inputs; };
          imports = [
            ./home
            inputs.stylix.homeModules.stylix
            inputs.niri.homeModules.config
            inputs.niri.homeModules.stylix
          ];
        };
      };
    }
  ];

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = "max";
      };
      efi.canTouchEfiVariables = true;
    };
    kernel.sysctl = {
      # Gaming-specific sysctls moved to gaming-optimizations.nix
    };
    tmp = {
      useTmpfs = true;
      tmpfsSize = "100%";
    };
  };

  # ZRAM swap configuration - only swap method used
  zramSwap = {
    enable = true;
    memoryPercent = 50;  # Use 50% of RAM for ZRAM (more reasonable than 100%)
    algorithm = "zstd";  # Use zstd compression for better performance
  };

  time.timeZone = "Asia/Yekaterinburg";

  i18n = {
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "ru_RU.UTF-8/UTF-8"
    ];

    defaultLocale = "en_US.UTF-8";

    extraLocaleSettings = {
      LC_TIME = "ru_RU.UTF-8";
    };
  };

  hardware = {
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
  };

  security = {
    doas = {
      enable = true;
      extraRules = [
        {
          groups = [ "wheel" ];
          noPass = true;
          keepEnv = true;
        }
      ];
    };
    sudo.enable = false;
    rtkit.enable = true;
  };

  users = {
    defaultUserShell = pkgs.zsh;

    users = {
      pyw0w = {
        isNormalUser = true;
        description = "PyW0W";
        extraGroups = [
          "wheel"
          "gamemode"
        ];
      };
    };
  };

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-extra
      noto-fonts-color-emoji
      noto-fonts-emoji
      # corefonts
      font-awesome
      iosevka
      open-dyslexic
      powerline-symbols
      fantasque-sans-mono
      inter
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "Fantasque Sans Mono" ];
        serif = [ "Noto Serif" ];
        sansSerif = [
          "Inter"
          "Noto Color Emoji"
        ];
      };
    };
  };

  # Centralized environment variables - all system environment variables are defined here
  environment = {
    sessionVariables = {
      # Core applications
      BROWSER = "${lib.getExe pkgs.librewolf}";
      EDITOR = "${lib.getExe pkgs.helix}";

      # Wayland/X11 display settings
      DISPLAY = ":0";  # X11 compatibility
      XDG_SESSION_TYPE = "wayland";
      GDK_BACKEND = "wayland";
      
      # NVIDIA graphics settings - optimized for Wayland stability
      # NIXOS_OZONE_WL = "1"; # causes flickering in electron apps
      LIBVA_DRIVER_NAME = "nvidia";
      GBM_BACKEND = "nvidia-drm";
      NVD_BACKEND = "direct";
      VK_DRIVER_FILES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json";
      CUDA_CACHE_PATH = "/tmp/cuda-cache";
      
      # Media libraries (for Minecraft and other applications)
      VLC_PLUGIN_PATH = "${pkgs.vlc}/lib/vlc/plugins";
      LIBVLC_PATH = "${pkgs.libvlc}/lib";

      # NVIDIA OpenGL settings - balanced for stability and performance
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      __GL_SHADER_DISK_CACHE = "1";
      __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";
      # Disabled problematic settings that cause EGL crashes:
      # __GL_GSYNC_ALLOWED = "1";  # Can cause issues with Wayland
      # __GL_VRR_ALLOWED = "1";    # Can cause issues with Wayland  
      # __GL_THREADED_OPTIMIZATIONS = "1";  # Can cause X11 app crashes
      
      # Gaming optimizations
      # Wine/Proton optimizations
      WINEFSYNC = "1";
      WINEESYNC = "1";
      WINE_CPU_TOPOLOGY = "4:2";  # Adjust based on your CPU
      
      # Gaming performance - safe settings
      # __GL_SYNC_TO_VBLANK = "0";  # Disabled - can cause Xwayland issues
      __GL_ALLOW_UNOFFICIAL_PROTOCOL = "1";
      
      # X11/Wayland stability settings
      XWAYLAND_NO_GLAMOR = "0";  # Enable glamor for better performance
      WLR_RENDERER = "gles2";    # Force GLES2 renderer for stability
      
      # Steam optimizations
      STEAM_FRAME_FORCE_CLOSE = "1";
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/mnt/games/SteamLibrary/compatibilitytools.d";
      RADV_PERFTEST = "gpl";  # For AMD users, but doesn't hurt NVIDIA
      
      # DXVK optimizations - conservative settings
      # DXVK_HUD = "fps,memory,gpuload";  # Disabled - can cause crashes
      DXVK_LOG_LEVEL = "warn";
      DXVK_STATE_CACHE_PATH = "/mnt/games/SteamLibrary/dxvk_cache";
    };
  };

  system.stateVersion = "24.05"; # do not change
}
