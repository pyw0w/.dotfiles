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
    
    # Additional Xwayland settings for NVIDIA compatibility
    displayManager.setupCommands = ''
      ${pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource modesetting NVIDIA-0
      ${pkgs.xorg.xrandr}/bin/xrandr --auto
    '';
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

  # Graphics configuration optimized for Niri
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
      
      # NVIDIA Wayland support
      egl-wayland           # EGL Wayland support
      
      # Additional video acceleration
      vaapiVdpau
      libva
      
      # OpenCL support
      nvidia-vaapi-driver
      
      # Better EGL support for Niri
      mesa.drivers
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
      "splash=silent"
      "quiet"
      # Removed problematic EDID firmware parameter that was causing errors
      # "drm.edid_firmware=edid/1920x1080.bin"
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

  # Improved NVIDIA device creation rules - fixed from logs analysis
  services.udev.extraRules = ''
    # NVIDIA device rules for proper device creation
    KERNEL=="nvidia", RUN+="${pkgs.coreutils}/bin/mknod -m 666 /dev/nvidiactl c 195 255"
    KERNEL=="nvidia[0-9]*", RUN+="${pkgs.bash}/bin/bash -c 'for i in 0 1 2 3; do [ -e /proc/driver/nvidia/gpus/0000:01:00.0/information ] && mknod -m 666 /dev/nvidia$i c 195 $i 2>/dev/null || true; done'"
    
    # Create nvidia-uvm devices with proper error handling
    KERNEL=="nvidia_uvm", RUN+="${pkgs.bash}/bin/bash -c 'mknod -m 666 /dev/nvidia-uvm c $(grep nvidia-uvm /proc/devices | cut -d \  -f 1) 0 2>/dev/null || true'"
    KERNEL=="nvidia_uvm", RUN+="${pkgs.bash}/bin/bash -c 'mknod -m 666 /dev/nvidia-uvm-tools c $(grep nvidia-uvm /proc/devices | cut -d \  -f 1) 1 2>/dev/null || true'"
  '';

  # Additional NVIDIA stability improvements
  environment.variables = {
    # Force NVIDIA to use the correct render node
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    LIBVA_DRIVER_NAME = "nvidia";
    # Improve EGL compatibility
    __EGL_VENDOR_LIBRARY_FILENAMES = "/run/opengl-driver/share/glvnd/egl_vendor.d/10_nvidia.json";
    
    # Wayland-specific optimizations
    GBM_BACKEND = "nvidia-drm";
    __GL_GSYNC_ALLOWED = "1";
    __GL_VRR_ALLOWED = "1";
    WLR_NO_HARDWARE_CURSORS = "1";  # May help with cursor issues in some cases
    
    # NVIDIA performance optimizations
    __GL_SHADER_DISK_CACHE = "1";
    __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";
    
    # Force NVIDIA as the primary GPU
    DRI_PRIME = "1";
  };

  # Blacklist nouveau driver to prevent conflicts
  boot.blacklistedKernelModules = [ "nouveau" ];
} 