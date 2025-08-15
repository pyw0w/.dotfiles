{
  ...
}:
{
  services.restic = {
    backups.r2 = {
      initialize = true;
      repository = "s3:https://67f502e1ead7cb06d017e56dfd5288ac.r2.cloudflarestorage.com/backup/kappacino";
      passwordFile = "/root/.secrets/RESTIC_PASSWORD_FILE";
      environmentFile = "/root/.secrets/RESTIC_R2_SECRETS";
      timerConfig = {
        OnCalendar = "03:00";
        Persistent = true;
      };
      exclude = [
        "node_modules"
        ".git"
        ".cache"
        "/var/cache"
        "/var/www/fi.supa.sh"
        "/var/lib/jellyfin/transcodes"
        "/home/minecraft/supa/bluemap/web/maps"
      ];
      paths = [
        "/home"
        "/var/www"
        "/var/lib"
        "/etc"
      ];
    };
  };
}
