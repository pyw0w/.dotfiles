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

  # NVIDIA configuration optimized for gaming
  hardware.nvidia = {
    # Modesetting is required for Wayland compositors
    modesetting.enable = true;

    # Enable NVIDIA Settings menu
    nvidiaSettings = true;

    # Power management settings
    powerManagement = {
      enable = true;  # Enable power management for better performance
      finegrained = false;  # Disable fine-grained power management (can cause issues)
    };

    # Use proprietary drivers (better performance than open-source)
    open = false;

    # Use production drivers (stable)
    package = config.boot.kernelPackages.nvidiaPackages.production;

    # Force full composition pipeline (reduces tearing)
    forceFullCompositionPipeline = true;
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

  # Gaming-optimized environment variables
  environment.sessionVariables = {
    # NVIDIA-specific variables
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GL_GSYNC_ALLOWED = "1";
    __GL_VRR_ALLOWED = "1";
    
    # Vulkan
    VK_DRIVER_FILES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json";
    
    # CUDA
    CUDA_CACHE_PATH = "/tmp/cuda-cache";
    
    # Performance optimizations
    __GL_SHADER_DISK_CACHE = "1";
    __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";
    __GL_THREADED_OPTIMIZATIONS = "1";
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

  # Additional gaming optimizations
  systemd.services.nvidia-powerd = {
    enable = true;
    description = "NVIDIA Power Management Daemon";
  };

  # OpenGL configuration for better performance
  hardware.nvidia.prime = {
    # Only enable if you have hybrid graphics (Intel + NVIDIA)
    # sync.enable = true;
    # offload.enable = false;
  };
} 