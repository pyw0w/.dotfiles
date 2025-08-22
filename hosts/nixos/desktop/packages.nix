{
  config,
  lib,
  pkgs,
  unstable,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    # Essential
    vim
    wget
    git
    xz
    htop
    bottom
    nvitop
    playerctl
    psmisc
    compsize
    pkg-config
    config.boot.kernelPackages.cpupower
    busybox
    libclang
    wl-clipboard
    doas-sudo-shim
  ];

  users.users.pyw0w.packages = with pkgs; [
    # Internet
    firefox
    # monero-gui # XMR wallet
    qbittorrent
    thunderbird
    discord

    # Utils/Misc
    kitty # Terminal
    foot
    fastfetch
    ffmpeg-full
    yt-dlp
    pavucontrol # Volume control
    flameshot # Screenshots
    songrec # Shazam song recognition
    filezilla
    curlie
    dig
    ripgrep
    gnupg
    session-desktop
    dbgate
    libreoffice
    zulu8
    zulu17

    # Dev
    code-cursor
    helix
    insomnia
    gh
    lazygit
    gcc
    nodejs
    typescript-language-server
    go
    gopls
    fenix.default.toolchain
    nil
    nixfmt-rfc-style
    php

    # Multimedia
    nsxiv # Image viewer
    mpv
    jellyfin-mpv-shim
    jellyfin-rpc
    audacity
    imagemagick

    # Games
    prismlauncher # Minecraft launcher

    # Other
    (pkgs.writeShellScriptBin "c2" ''
      export QT_QPA_PLATFORM=xcb
      exec ${lib.getExe technorino} "$@"
    '')
  ];
}
