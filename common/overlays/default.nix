# Custom overlays loader
# Loads overlays from categorized subdirectories for better organization
let
  # Load overlays from categorized directories
  loadFromDir = dir: 
    let
      path = ./. + "/${dir}";
      overlays = import path;
    in
    if builtins.pathExists path then overlays else [];

  # Define overlay categories
  categories = [
    "applications"  # Application-specific overlays
    "development"   # Development tool overlays  
    "system"        # System-level overlays
  ];

  # Load all overlays from categories
  categoryOverlays = builtins.concatLists (map loadFromDir categories);

  # Load any standalone overlay files in the root directory
  dir = ./.;
  files = builtins.attrNames (builtins.readDir dir);
  standaloneFiles = builtins.filter (
    name: name != "default.nix" 
          && builtins.match ".*\\.nix" name != null
          && !(builtins.elem (builtins.replaceStrings [".nix"] [""] name) categories)
  ) files;
  standaloneOverlays = map (name: import (dir + "/${name}")) standaloneFiles;

in
categoryOverlays ++ standaloneOverlays
