{ config, pkgs, ... }:

{ 
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  
  # NVIDIA configuration for Wayland compatibility
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    open = true;  # Required for NVIDIA driver versions >= 560
    modesetting.enable = true;
    powerManagement.enable = true;
    prime = {
      offload.enable = false;  # Disable for desktop setup
    };
  };

  # X11 configuration (fallback)
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
  };

  environment.systemPackages = with pkgs; [
    john
    ocl-icd
    clinfo
    # Additional graphics tools
    vulkan-tools
    vulkan-loader
    vulkan-validation-layers
  ];
}