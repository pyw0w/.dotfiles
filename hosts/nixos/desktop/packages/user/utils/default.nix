{
  pkgs,
  ...
}:
{
  users.users.pyw0w.packages = with pkgs; [
    # Utils/Misc
    kitty # Terminal
    foot
    fastfetch
    ffmpeg-full
    yt-dlp
    pavucontrol # Volume control
    flameshot # Screenshots
    songrec # Shazam song recognition
    filezilla
    curlie
    dig
    ripgrep
    gnupg
    session-desktop
    dbgate
    libreoffice
    zulu8
    zulu17
  ];
} 