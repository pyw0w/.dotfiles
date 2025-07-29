{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Node.js
    nodejs_20
    nodePackages.npm
    
    # Basic tools
    nodePackages.typescript
    nodePackages.eslint
    nodePackages.prettier
  ];
}
