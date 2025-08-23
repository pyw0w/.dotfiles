{
  config,
  lib,
  pkgs,
  ...
}:
{
  # X server configuration with NVIDIA driver
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
  };

  # NVIDIA configuration optimized for gaming and Wayland
  hardware.nvidia = {
    # Modesetting is required for Wayland compositors
    modesetting.enable = true;

    # Enable NVIDIA Settings menu
    nvidiaSettings = true;

    # Power management settings - disabled for stability with Wayland
    powerManagement = {
      enable = false;  # Disable to prevent EGL crashes with Xwayland
      finegrained = false;
    };

    # Use proprietary drivers (better performance than open-source)
    open = false;

    # Use production drivers (stable)
    package = config.boot.kernelPackages.nvidiaPackages.production;

    # Disable force full composition pipeline for Wayland compatibility
    # forceFullCompositionPipeline = false;  # This setting can cause issues with Wayland
  };

  # Graphics configuration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;  # Enable 32-bit support for older games

    extraPackages = with pkgs; [
      # NVIDIA specific packages
      nvidia-vaapi-driver    # VAAPI support for hardware video decoding
      libvdpau-va-gl        # VDPAU to VA-API translation
      vulkan-loader         # Vulkan support
      vulkan-validation-layers
      vulkan-tools          # Vulkan utilities (vulkaninfo, etc.)
      
      # Additional video acceleration
      vaapiVdpau
      libva
      
      # OpenCL support
      nvidia-vaapi-driver
    ];

    extraPackages32 = with pkgs.pkgsi686Linux; [
      nvidia-vaapi-driver
      libvdpau-va-gl
      vulkan-loader
      vulkan-validation-layers
    ];
  };

  # Boot parameters for NVIDIA
  boot = {
    kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
    kernelParams = [
      "nvidia_drm.modeset=1"
      "nvidia_drm.fbdev=1"
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"  # Suspend/resume fix
    ];
    
    # Early loading of NVIDIA modules
    initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  };

  # Additional gaming optimizations - disabled for Wayland stability
  # systemd.services.nvidia-powerd = {
  #   enable = false;  # Disabled - can cause EGL/X11 crashes
  #   description = "NVIDIA Power Management Daemon";
  # };

  # OpenGL configuration for better performance
  hardware.nvidia.prime = {
    # Only enable if you have hybrid graphics (Intel + NVIDIA)
    # sync.enable = true;
    # offload.enable = false;
  };
} 