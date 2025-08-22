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
    discord
  ];
} 