{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Minecraft launchers
    prismlauncher  # Modern Minecraft launcher with mod support
    # minecraft  # Official Minecraft launcher (if available)
    
    # Minecraft development tools
    fabric-installer
    # forge-installer  # Not available in nixpkgs, use manual installation
    
    # Additional tools
    jq
  ];

  # Minecraft configuration with Java compatibility
  # Note: Minecraft folder will be created automatically by PrismLauncher

  # Java compatibility settings
  home.sessionVariables = {
    # Default Java version
    JAVA_HOME = "${pkgs.jdk17}";
    
    # Java alternatives for compatibility
    JAVA_8_HOME = "${pkgs.jdk8}";
    JAVA_17_HOME = "${pkgs.jdk17}";
    JAVA_21_HOME = "${pkgs.jdk21}";
    
    # Add all Java versions to PATH (as string)
    PATH = "${pkgs.jdk17}/bin:${pkgs.jdk8}/bin:${pkgs.jdk21}/bin:$PATH";
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

  # Java version switcher script
  home.file.".local/bin/java-switch" = {
    text = ''
      #!/bin/bash
      # Switch between Java versions
      
      case "$1" in
        "8"|"jdk8")
          export JAVA_HOME=${pkgs.jdk8}
          export PATH="$JAVA_HOME/bin:$PATH"
          echo "Switched to Java 8"
          ;;
        "17"|"jdk17")
          export JAVA_HOME=${pkgs.jdk17}
          export PATH="$JAVA_HOME/bin:$PATH"
          echo "Switched to Java 17"
          ;;
        "21"|"jdk21")
          export JAVA_HOME=${pkgs.jdk21}
          export PATH="$JAVA_HOME/bin:$PATH"
          echo "Switched to Java 21"
          ;;
        *)
          echo "Usage: java-switch [8|17|21]"
          echo "Current JAVA_HOME: $JAVA_HOME"
          echo "Available versions:"
          echo "  JAVA_8_HOME: ${pkgs.jdk8}"
          echo "  JAVA_17_HOME: ${pkgs.jdk17}"
          echo "  JAVA_21_HOME: ${pkgs.jdk21}"
          ;;
      esac
    '';
    executable = true;
  };
} 