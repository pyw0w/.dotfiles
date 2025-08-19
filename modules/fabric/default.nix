# build custom widgets
args@{ config, lib, pkgs, variables, ... }:
let
  fabricEnv = pkgs.python3.withPackages (ps: [ pkgs.local.fabric ]);
  fabricRunner = pkgs.writeShellScriptBin "fabric-run" ''
    export GI_TYPELIB_PATH=${pkgs.gtk3}/lib/girepository-1.0:${pkgs.gdk-pixbuf}/lib/girepository-1.0:${pkgs.gobject-introspection}/lib/girepository-1.0:${pkgs.libdbusmenu-gtk3}/lib/girepository-1.0:${pkgs.gtk-layer-shell}/lib/girepository-1.0:$GI_TYPELIB_PATH
    export GSETTINGS_SCHEMA_DIR=${pkgs.gsettings-desktop-schemas}/share/glib-2.0/schemas:${pkgs.gtk3}/share/glib-2.0/schemas:$GSETTINGS_SCHEMA_DIR
    exec ${fabricEnv}/bin/python %h/.config/fabric/main.py
  '';
in
lib.mkModule "fabric" config {
  environment.systemPackages = [
    pkgs.local.fabric
  ];

  # symlink config to ~/.config
  home-manager.users.${variables.username} = { config, ... }: {
    xdg.configFile."fabric" = {
      source = config.lib.file.mkOutOfStoreSymlink "/etc/dotfiles/modules/fabric/config";
      recursive = true;
    };

    systemd.user.services.fabric = {
      Unit = {
        Description = "Fabric widgets (Hyprland)";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${fabricRunner}/bin/fabric-run";
        Restart = "on-failure";
        RestartSec = 2;
        Environment = [ "PYTHONUNBUFFERED=1" ];
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}