# System-level overlays
# Modifications to system packages and libraries
let
  dir = ./.;
  files = builtins.attrNames (builtins.readDir dir);
  nixFiles = builtins.filter (
    name: name != "default.nix" && builtins.match ".*\\.nix" name != null
  ) files;
in
map (name: import (dir + "/${name}")) nixFiles 