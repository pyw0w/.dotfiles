{ config, pkgs, ... }:

{ 
  # Minimal NVIDIA configuration for desktop RTX 3060
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;
    open = true;
  };

  # Graphics support
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # CUDA packages
  environment.systemPackages = with pkgs; [
    cudaPackages.cudatoolkit
    cudaPackages.cudnn
  ];

  # CUDA environment variables
  environment.variables = {
    CUDA_PATH = "/run/current-system/sw";
    CUDA_HOME = "/run/current-system/sw";
  };
}