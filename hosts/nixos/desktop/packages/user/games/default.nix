{
  pkgs,
  ...
}:
{
  imports = [
    ./minecraft-media.nix  # Media support for Minecraft and games
  ];

  users.users.pyw0w.packages = with pkgs; [
    # Games
    prismlauncher # Minecraft launcher
  ];
} 