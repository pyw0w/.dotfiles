{
  pkgs,
  ...
}:
{
  users.users.pyw0w.packages = with pkgs; [
    # Games
    prismlauncher # Minecraft launcher
  ];
} 