{ config, pkgs, ... }:

{ 
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  
  # NVIDIA configuration for Wayland and CUDA compatibility
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    open = true;  # Required for NVIDIA driver versions >= 560
    modesetting.enable = true;
    powerManagement.enable = true;
    prime = {
      offload.enable = false;  # Disable for desktop setup
    };
    # CUDA support
    nvidiaPersistenced = true;
    # Enable all NVIDIA features
    settings = {
      # Performance settings
      CoolBits = "28";
      # CUDA settings
      UseEvents = "On";
      # Power management
      PowerMizerEnable = "1";
      PowerMizerLevel = "1";
    };
  };

  # X11 configuration (fallback)
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
  };

  # CUDA environment variables
  environment.variables = {
    # CUDA paths
    CUDA_PATH = "${pkgs.cudaPackages.cudatoolkit}";
    CUDA_HOME = "${pkgs.cudaPackages.cudatoolkit}";
    CUDA_ROOT = "${pkgs.cudaPackages.cudatoolkit}";
    
    # CUDA libraries
    LD_LIBRARY_PATH = "${pkgs.cudaPackages.cudatoolkit}/lib64:${pkgs.cudaPackages.cudnn}/lib:$LD_LIBRARY_PATH";
    
    # CUDA development
    CUDA_INC_PATH = "${pkgs.cudaPackages.cudatoolkit}/include";
    CUDA_LIB_PATH = "${pkgs.cudaPackages.cudatoolkit}/lib64";
    
    # PyTorch CUDA
    TORCH_CUDA_ARCH_LIST = "6.1";  # RTX 3060 architecture
    CUDA_VISIBLE_DEVICES = "0";
    
    # Performance optimizations
    CUDA_LAUNCH_BLOCKING = "0";
    CUDA_CACHE_DISABLE = "0";
  };

  environment.systemPackages = with pkgs; [
    john
    ocl-icd
    clinfo
    # Additional graphics tools
    vulkan-tools
    vulkan-loader
    vulkan-validation-layers
    # CUDA packages
    cudaPackages.cudatoolkit
    cudaPackages.cudnn
    cudaPackages.cuda-samples
    # Machine learning with CUDA
    python3Packages.torch
    python3Packages.torchvision
    python3Packages.torchaudio
    # CUDA utilities
    nvidia-cuda-toolkit
    cudaPackages.cuda-gdb
    cudaPackages.cuda-memcheck
  ];
}