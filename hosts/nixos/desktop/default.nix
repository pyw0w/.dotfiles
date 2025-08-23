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
    ./services.nix
    ./programs.nix
    ./nh.nix
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
      "vm.swappiness" = 1;
    };
    tmp = {
      useTmpfs = true;
      tmpfsSize = "100%";
    };
  };

  zramSwap = {
    enable = true;
    memoryPercent = 100;
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
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        nvidia-vaapi-driver
        libvdpau-va-gl
      ];
    };

    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
    };

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

  environment = {
    sessionVariables = {
      BROWSER = "${lib.getExe pkgs.librewolf}";
      EDITOR = "${lib.getExe pkgs.helix}";

      # NIXOS_OZONE_WL = "1"; # causes flickering in electron apps
      LIBVA_DRIVER_NAME = "nvidia";
      XDG_SESSION_TYPE = "wayland";
      GDK_BACKEND = "wayland";
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      NVD_BACKEND = "direct";
    };
  };

  system.stateVersion = "24.05"; # do not change
}
