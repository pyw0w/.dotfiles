{
  pkgs,
  ...
}:
{
  # Minecraft and games media support
  users.users.pyw0w.packages = with pkgs; [
    # Java Native Access for VLC and native libraries
    jna
    
    # Additional codecs for games
    x264
    x265
    
    # OpenAL for game audio (required by Minecraft)
    openal
    alsa-lib
    
    # Additional media libraries that games might need
    SDL2
    SDL2_mixer
    SDL2_image
    
    # GLFW for window management
    glfw
  ];
  
  # System-wide packages for media support
  environment.systemPackages = with pkgs; [
    # VLC Java bindings (if available)
    # vlcj # This might not be available in nixpkgs
  ];
} 