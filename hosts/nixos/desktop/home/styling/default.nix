{
  inputs,
  pkgs,
  ...
}:
{
  stylix = {
    enable = true;
    overlays.enable = false;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine-moon.yaml";
    image = inputs.self + /assets/wallpaper.jpg;

    fonts = {
      sizes = {
        applications = 12;
        desktop = 12;
      };

      serif = {
        package = pkgs.noto-fonts;
        name = "Noto Serif";
      };

      sansSerif = {
        package = pkgs.inter;
        name = "Inter";
      };

      monospace = {
        package = pkgs.fantasque-sans-mono;
        name = "Fantasque Sans Mono";
      };

      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
    };

    opacity = {
      desktop = 0.8;
      popups = 0.8;
      terminal = 0.8;
    };

    cursor = {
      name = "BreezeX-RosePineDawn-Linux";
      package = pkgs.rose-pine-cursor;
      size = 18;
    };
  };
} 