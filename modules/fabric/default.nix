# build custom widgets
args@{ config, lib, pkgs, variables, ... }:
let
  fabricEnv = pkgs.python3.withPackages (ps: [ pkgs.local.fabric ]);
in
lib.mkModule "fabric" config {
  environment.systemPackages = [
    pkgs.local.fabric
  ];

  # symlink config to ~/.config
  home-manager.users.${variables.username} = { config, ... }: {
    xdg.configFile."fabric" = {
      source = config.lib.file.mkOutOfStoreSymlink "/etc/dotfiles/modules/fabric";
      recursive = true;
    };

    systemd.user.services.fabric = {
      Unit = {
        Description = "Fabric widgets (Hyprland)";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${fabricEnv}/bin/python -m fabric";
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