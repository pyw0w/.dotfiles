{
  pkgs,
  ...
}:
{
  programs.obs-studio = {
    enable = true;
    package = pkgs.obs-studio.override {
      cudaSupport = true;
    };
    plugins = with pkgs.obs-studio-plugins; [
      obs-gstreamer
      waveform
      obs-pipewire-audio-capture
    ];
  };
} 