{ config, ... }:

{ 
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;
    open = true; # Use open source kernel modules for RTX 3060 (Turing architecture)
    prime = {
      offload.enable = false; # Explicitly disable PRIME offload
      sync.enable = false; # Explicitly disable PRIME sync
    };
  };
}