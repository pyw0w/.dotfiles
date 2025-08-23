{
  pkgs,
  ...
}:
{
  # Nautilus (GNOME Files) file manager
  services.gnome.gnome-keyring.enable = true;  # Required for Nautilus
  
  # Install Nautilus and related packages
  environment.systemPackages = with pkgs; [
    nautilus              # GNOME Files (Nautilus)
    gnome-keyring         # For password management
    gnome-settings-daemon # For proper integration
    gvfs                  # Virtual filesystem support
    
    # File manager extensions and utilities
    file-roller           # Archive manager integration
    evince               # PDF viewer integration
    eog                  # Image viewer integration
    
    # Thumbnails and previews
    gnome-epub-thumbnailer
    ffmpegthumbnailer
    webp-pixbuf-loader
  ];

  # Enable GNOME VFS for file management
  services.gvfs.enable = true;
  
  # D-Bus services for Nautilus
  services.dbus.packages = with pkgs; [
    nautilus
    gnome-settings-daemon
  ];

  # Portal for file dialogs
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-gnome
  ];
} 