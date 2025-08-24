{
  pkgs,
  ...
}:
{
  users.users.pyw0w.packages = with pkgs; [
    # Internet
    firefox
    qbittorrent
    
    # Discord alternative with better performance and plugins
    equibop  # Modern Discord client with Equicord plugins built-in
    #discord  # Replaced with equibop - uncomment if needed
  ];
} 