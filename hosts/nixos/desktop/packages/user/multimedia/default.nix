{
  pkgs,
  ...
}:
{
  users.users.pyw0w.packages = with pkgs; [
    # Multimedia
    nsxiv # Image viewer
    mpv   # Lightweight media player
    vlc   # Full-featured media player
    
    # VLC development libraries for applications like Minecraft
    libvlc
    
    # Audio/Video codecs and libraries
    ffmpeg
    ffmpeg-full
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
    
    # Audio tools
    audacity
    imagemagick
  ];
} 