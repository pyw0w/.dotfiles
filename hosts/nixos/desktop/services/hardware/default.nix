{
  ...
}:
{
  imports = [
    ./nvidia.nix              # NVIDIA configuration for gaming
    ./gaming-optimizations.nix # Gaming performance optimizations
  ];

  services = {
    blueman.enable = true;   # Bluetooth manager
  };
} 