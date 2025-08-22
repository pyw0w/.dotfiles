{
  ...
}:
{
  imports = [
    # Styling and themes
    ./styling

    # Shell configuration  
    ./shell

    # Applications and programs
    ./applications

    # Desktop environment (niri, waybar)
    ./desktop

    # XDG and file associations
    ./xdg
  ];

  # Home Manager settings
  news.display = "silent";
  programs.home-manager.enable = true;
}
