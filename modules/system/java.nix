{ config, pkgs, ... }:

{
  # Java development environment with compatibility
  environment.systemPackages = with pkgs; [
    # Java Development Kits (multiple versions for compatibility)
    jdk8   # For older applications
    jdk17  # Recommended for Minecraft 1.20.1
    jdk21  # Latest LTS version
    
    # Java tools
    gradle
    maven
    
    # Minecraft development tools
    fabric-installer
    # forge-installer  # Not available in nixpkgs, use manual installation
    
    # Java utilities
    jq
  ];

  # Set JAVA_HOME to JDK 17 by default
  environment.variables = {
    JAVA_HOME = "${pkgs.jdk17}";
    PATH = [ "${pkgs.jdk17}/bin" ];
  };

  # Java alternatives system for compatibility
  programs.java = {
    enable = true;
    package = pkgs.jdk17;
  };

  # Java alternatives configuration
  environment.etc."java-8-openjdk".source = pkgs.jdk8;
  environment.etc."java-17-openjdk".source = pkgs.jdk17;
  environment.etc."java-21-openjdk".source = pkgs.jdk21;
} 