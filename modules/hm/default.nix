{ pkgs, inputs, unstable, ... }:

{
  imports = [
    # ./example.nix - add your modules here
    ./russian.nix
    ./scripts.nix
    ../dev
    inputs.yandex-music.homeManagerModules.default
  ];

  # home-manager options go here
  home.packages = [
    inputs.zen-browser.packages.${pkgs.system}.default
    unstable.code-cursor
    pkgs.zed-editor
    # pkgs.vscode - hydenix's vscode version
    # pkgs.userPkgs.vscode - your personal nixpkgs version
  ];

  # Yandex Music configuration
  programs.yandex-music = {
    enable = true;
    tray.enable = true; # to enable tray support
  };

  # hydenix home-manager options go here
  hydenix.hm = {
    #! Important options
    enable = true;
    /*
      ! Below are defaults, no need to uncomment them all
      comma.enable = true; # useful nix tool to run software without installing it first
      dolphin.enable = true; # file manager
      fastfetch.enable = true; # fastfetch configuration
      hyde.enable = true; # enable hyde module
      lockscreen = {
        enable = true; # enable lockscreen module
        hyprlock = true; # enable hyprlock lockscreen
        swaylock = false; # enable swaylock lockscreen
      };
      notifications.enable = true; # enable notifications module
      qt.enable = true; # enable qt module
      rofi.enable = true; # enable rofi module
      screenshots = {
        enable = true; # enable screenshots module
        grim.enable = true; # enable grim screenshot tool
        slurp.enable = true; # enable slurp region selection tool
        satty.enable = false; # enable satty screenshot annotation tool
        swappy.enable = true; # enable swappy screenshot editor
      };
      shell = {
        enable = true; # enable shell module
        zsh = {
          enable = true; # enable zsh shell
          plugins = [ "sudo" ]; # zsh plugins
          configText = ""; # zsh config text
        };
        bash.enable = false; # enable bash shell
        fish.enable = false; # enable fish shell
        pokego.enable = false; # enable Pokemon ASCII art scripts
        p10k.enable = false; # enable p10k prompt
        starship.enable = true; # enable starship prompt
      };
      swww.enable = true; # enable swww wallpaper daemon
      terminals = {
        enable = true; # enable terminals module
        kitty = {
          enable = true; # enable kitty terminal
          configText = ""; # kitty config text
        };
      };
      waybar = {
        enable = true; # enable waybar module
        userStyle = ""; # custom waybar user-style.css
      };
      wlogout.enable = true; # enable wlogout module
      xdg.enable = true; # enable xdg module
    */
    editors = {
      enable = true; # enable editors module
      neovim = false; # enable neovim module
      vim = false; # enable vim module
      vscode = {
        enable = false; # enable vscode module
        wallbash = true; # enable wallbash extension for vscode
      };
      default = "cursor"; # default text editor
    };
    theme = {
      enable = true; # enable theme module
      active = "Tokyo Night"; # active theme name
      themes = [
        "Catppuccin Mocha"
        "Tokyo Night"
      ]; # default enabled themes, full list in https://github.com/richen604/hydenix/tree/main/hydenix/sources/themes
    };
    spotify.enable = false; # enable spotify module
    social = {
      enable = true; # enable social module
      discord.enable = false; # enable discord module
      webcord.enable = false; # enable webcord module
      vesktop.enable = true; # enable vesktop module
    };
    git = {
      enable = true; # enable git module
      name = "pyw0w"; # git user name eg "John Doe"
      email = "myxi2002@gmail.com"; # git user email eg "john.doe@example.com"
    };
    firefox.enable = false; # enable firefox module
    hyprland = {
      enable = true; # enable hyprland module
                extraConfig = ''
          # Keyboard configuration
          input {
            kb_layout = us,ru
            kb_options = grp:alt_shift_toggle
          }
          # Keyboard language switcher
          bind = ALT, SHIFT, exec, hyprctl switchxkblayout at-translated-set-2-keyboard next
          
          # Disable automatic screen blanking
          misc {
            disable_autoreload = true
          }
          
          # Power management - disable screen blanking
          general {
            allow_tearing = false
          }
          
          # Disable automatic screen blanking
          env = XDG_SESSION_TYPE,wayland
          env = XDG_CURRENT_DESKTOP,Hyprland
          
          # Screen management shortcuts
          bind = SUPER, F1, exec, ~/.local/bin/toggle-screen
          bind = SUPER, F2, exec, ~/.local/bin/disable-screen-blanking
          bind = SUPER, F3, exec, hyprctl dispatch dpms off
          bind = SUPER, F4, exec, hyprctl dispatch dpms on
        '';
    };
  };
}
