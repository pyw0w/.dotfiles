{
  config,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    # Essential system packages
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
} 