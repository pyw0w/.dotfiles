{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Minecraft launchers
    prismlauncher  # Modern Minecraft launcher with mod support
    # minecraft  # Official Minecraft launcher (if available)
    
    # Minecraft development tools
    fabric-installer
    # forge-installer  # Not available in nixpkgs, use manual installation
    
    # Java tools for Minecraft
    jdk17
    jdk21
    
    # Additional tools
    jq
  ];

  # Minecraft configuration
  home.file.".local/share/minecraft" = {
    target = ".minecraft";
    recursive = true;
  };

  # Create Minecraft launcher shortcuts
  home.file.".local/bin/minecraft" = {
    text = ''
      #!/bin/bash
      # Launch Minecraft with optimal Java settings
      export JAVA_HOME=${pkgs.jdk17}
      export PATH="$JAVA_HOME/bin:$PATH"
      
      # Launch PrismLauncher
      prismlauncher "$@"
    '';
    executable = true;
  };

  home.file.".local/bin/minecraft-dev" = {
    text = ''
      #!/bin/bash
      # Launch Minecraft with development tools
      export JAVA_HOME=${pkgs.jdk17}
      export PATH="$JAVA_HOME/bin:$PATH"
      
      # Set development environment
      export MINECRAFT_DEV_MODE=1
      
      # Launch with development settings
      prismlauncher --dev "$@"
    '';
    executable = true;
  };
} 