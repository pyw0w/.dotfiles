{
  lib,
  pkgs,
  ...
}:
{
  users.users.pyw0w.packages = with pkgs; [
    # Other
    (pkgs.writeShellScriptBin "c2" ''
      export QT_QPA_PLATFORM=xcb
      exec ${lib.getExe technorino} "$@"
    '')
  ];
} 