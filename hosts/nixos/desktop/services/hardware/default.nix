{
  ...
}:
{
  imports = [
    ./nvidia.nix              # NVIDIA configuration for gaming
    ./gaming-optimizations.nix # Gaming performance optimizations
  ];

  services = {
    gvfs.enable = true;      # Virtual filesystem support
    blueman.enable = true;   # Bluetooth manager
  };
} 