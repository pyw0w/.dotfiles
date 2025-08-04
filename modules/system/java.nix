{ config, pkgs, ... }:

{
  # Java development environment
  environment.systemPackages = with pkgs; [
    # Java Development Kits
    jdk17  # Recommended for Minecraft 1.20.1
    jdk21  # Latest LTS version, also works with Minecraft 1.20.1
    
    # Java tools
    gradle
    maven
    
    # Minecraft development tools
    fabric-installer
    # forge-installer  # Not available in nixpkgs, use manual installation
    
    # Java utilities
    jq
    jdk8  # Some older tools might need it
  ];

  # Set JAVA_HOME to JDK 17 by default
  environment.variables = {
    JAVA_HOME = "${pkgs.jdk17}";
    PATH = [ "${pkgs.jdk17}/bin" ];
  };

  # Java alternatives system
  programs.java = {
    enable = true;
    package = pkgs.jdk17;
  };
} 