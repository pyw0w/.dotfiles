{
  pkgs,
  ...
}:
{
  users.users.pyw0w.packages = with pkgs; [
    # Multimedia
    nsxiv # Image viewer
    mpv
    audacity
    imagemagick
  ];
} 