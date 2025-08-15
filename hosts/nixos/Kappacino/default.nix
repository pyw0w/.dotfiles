{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware.nix
    ./users.nix
  ] ++ (import ./services);

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 1;
    };
    kernel.sysctl = {
      "vm.swappiness" = 1;
      "vm.nr_hugepages" = 4096;
    };
    tmp = {
      useTmpfs = true;
      tmpfsSize = "50%";
    };
  };

  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  networking = {
    interfaces.enp2s0.wakeOnLan.enable = true;
    nftables.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [
        80
        443
        57386 # bittorrent
        25565 # Minecraft
        1935 # RTMP
        8554 # RTSP
        # 8889 # WebRTC (HTTP) [live.supa.sh]
        30120 # FiveM
        # 30169 # FiveM testing
      ];
      allowedUDPPorts = [
        80
        443
        57386 # bittorrent
        8080 # srt-relay
        8189 # WebRTC (ICE)
        8890 # SRT
        30120 # FiveM
        24454 # Minecraft (voicechat)
      ];
    };
  };

  time.timeZone = "UTC";

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      intel-compute-runtime # OpenCL filter support (hardware tonemapping and subtitle burn-in)
    ];
  };

  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  }; # Force intel-media-driver

  security = {
    sudo.wheelNeedsPassword = false;
    sudo.execWheelOnly = true;
    rtkit.enable = true;
  };

  systemd.tmpfiles.settings = {
    "10-custom-permissions-nix-build-${toString builtins.currentTime}" = {
      "/mnt/hdd_4t".Z = {
        mode = "0775";
        user = "supa";
      };
      "/mnt/hdd_4t/movies".Z = {
        mode = "2770";
        group = "media";
      };
      "/mnt/hdd_4t/music".Z = {
        mode = "2770";
        group = "media";
      };
      "/mnt/hdd_500g".Z = {
        mode = "2770";
        group = "media";
      };
      "/var/www".Z = {
        mode = "2770";
        user = "supa";
        group = "www";
      };
      "/home/minecraft".Z = {
        mode = "2770";
        group = "minecraft";
      };
      "/home/fivem".Z = {
        mode = "2770";
        user = "fivem";
        group = "fivem";
      };
    };
  };

  services = {
    xserver.videoDrivers = [ "intel" ];

    openssh = {
      enable = true;
      ports = [ 38126 ];
      settings.PasswordAuthentication = false;
      openFirewall = true;
    };

    udev.enable = true;

    smartd.enable = true;

    vnstat.enable = true;

    jellyfin.enable = true;

    postgresql = {
      enable = true;
      enableTCPIP = true;
    };

    mysql = {
      enable = true;
      package = pkgs.mariadb;
    };

    clickhouse.enable = true;

    redis.servers = {
      "" = {
        enable = true;
        port = 6379;
      };
      "roles_lookup" = {
        enable = true;
        port = 6380;
      };
      "umami" = {
        enable = true;
        port = 6381;
      };
    };
  };

  environment.etc."clickhouse-server/config.xml".source =
    lib.mkForce ./etc/clickhouse-server/config.xml;

  system.stateVersion = "23.11"; # do not change
}
