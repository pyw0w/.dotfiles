{
  ...
}:
{
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = "thunar.desktop";

      "applications/x-www-browser" = "librewolf.desktop";
      "x-scheme-handler/http" = "librewolf.desktop";
      "x-scheme-handler/https" = "librewolf.desktop";
      "x-scheme-handler/chrome" = "librewolf.desktop";
      "x-scheme-handler/about" = "librewolf.desktop";
      "x-scheme-handler/unknown" = "librewolf.desktop";
      "application/x-extension-htm" = "librewolf.desktop";
      "application/x-extension-html" = "librewolf.desktop";
      "application/x-extension-shtml" = "librewolf.desktop";
      "application/xhtml+xml" = "librewolf.desktop";
      "application/x-extension-xhtml" = "librewolf.desktop";
      "application/x-extension-xht" = "librewolf.desktop";
      "application/pdf" = "librewolf.desktop";

      "text/html" = "codium.desktop";
      "text/plain" = "codium.desktop";
      "application/octet-stream" = "codium.desktop";
      "application/x-zerosize" = "codium.desktop";

      "image/png" = "nsxiv.desktop";
      "image/jpg" = "nsxiv.desktop";
      "image/jpeg" = "nsxiv.desktop";
      "image/gif" = "nsxiv.desktop";
      "image/webp" = "nsxiv.desktop";
      "image/heic" = "nsxiv.desktop";
      "image/apng" = "nsxiv.desktop";
      "image/svg+xml" = "nsxiv.desktop";

      "video/*" = "mpv.desktop";
    };
  };
} 