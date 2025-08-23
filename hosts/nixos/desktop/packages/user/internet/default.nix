{
  pkgs,
  ...
}:
{
  users.users.pyw0w.packages = with pkgs; [
    # Internet
    firefox
    # monero-gui # XMR wallet
    qbittorrent
    thunderbird
    
    # Discord alternative with better performance and plugins
    equibop  # Modern Discord client with Equicord plugins built-in
    #discord  # Replaced with equibop - uncomment if needed
  ];
} 