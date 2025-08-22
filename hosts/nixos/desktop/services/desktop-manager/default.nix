{
  lib,
  pkgs,
  ...
}:
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = ''${lib.getExe pkgs.greetd.tuigreet} --time --cmd niri-session'';
        user = "pyw0w";
      };
    };
  };
} 