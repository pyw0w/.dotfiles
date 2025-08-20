# git gui
args@{ config, lib, pkgs, variables, ... }:
lib.mkModule "ashell" config {
  environment.systemPackages = [ pkgs.unstable.ashell ];

  # required by ashell brightness and power modules
  services.upower.enable = true;

  # create config and user service
  home-manager.users.${variables.username} = { config, ... }: {
    xdg.configFile."ashell/config.toml".source =
      config.lib.file.mkOutOfStoreSymlink "/etc/dotfiles/modules/ashell/config.toml";

    systemd.user.services.ashell = {
      Unit = {
        Description = "Ashell status bar";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.unstable.ashell}/bin/ashell --config-path %h/.config/ashell/config.toml";
        Restart = "on-failure";
        RestartSec = 2;
        Environment = [ "WGPU_BACKEND=gl" ];
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}