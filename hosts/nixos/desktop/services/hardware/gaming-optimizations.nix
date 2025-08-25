{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Gaming-specific kernel parameters
  boot.kernel.sysctl = {
    # Network optimizations for gaming
    "net.core.rmem_default" = 262144;
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_default" = 262144;
    "net.core.wmem_max" = 16777216;
    "net.ipv4.tcp_rmem" = "4096 65536 16777216";
    "net.ipv4.tcp_wmem" = "4096 65536 16777216";
    "net.core.netdev_max_backlog" = 5000;
    
    # Memory management optimized for ZRAM-only setup
    "vm.swappiness" = 180;  # Higher value for ZRAM (compressed memory)
    "vm.vfs_cache_pressure" = 50;
    "vm.dirty_background_ratio" = 5;
    "vm.dirty_ratio" = 10;
    "vm.page-cluster" = 0;  # Disable swap readahead for ZRAM
  };

  # Install gaming-related packages
  environment.systemPackages = with pkgs; [
    # Performance monitoring
    mangohud     # Gaming overlay with performance metrics
    goverlay     # GUI for MangoHud configuration
    
    # Wine/Proton tools
    winetricks
    protontricks
    
    # Vulkan tools
    vulkan-tools
    vulkan-loader
    vulkan-validation-layers
    
    # Additional gaming utilities
    lutris            # Game launcher for non-Steam games
    
    # System monitoring
    htop
    nvtopPackages.nvidia  # NVIDIA GPU monitoring
  ];

  # Gaming-optimized systemd services
  systemd.services.gaming-optimizations = {
    description = "Apply gaming optimizations";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "gaming-optimizations" ''
        # Create DXVK cache directory
        mkdir -p /mnt/games/SteamLibrary/dxvk_cache
        chown pyw0w:users /mnt/games/SteamLibrary/dxvk_cache
        
        # Set CPU governor to performance
        echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor || true
        
        # Disable CPU power saving features for gaming
        echo 0 | tee /sys/devices/system/cpu/cpu*/power/energy_perf_bias || true
      '';
      RemainAfterExit = true;
    };
  };

  # Increase file descriptor limits for games
  security.pam.loginLimits = [
    {
      domain = "pyw0w";
      type = "hard";
      item = "nofile";
      value = "524288";
    }
    {
      domain = "pyw0w";
      type = "soft";
      item = "nofile";
      value = "524288";
    }
  ];

  # Enable GameMode for automatic game optimizations
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 10;        # Lower nice value for games
        ioprio = 0;         # Highest I/O priority
        inhibit_screensaver = 1;
        softrealtime = "auto";
      };
      
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;     # Use first GPU (NVIDIA)
        nv_powermizer_mode = 1;  # Prefer maximum performance
      };
      
      cpu = {
        park_cores = "no";
        pin_cores = "no";
      };
    };
  };
} 