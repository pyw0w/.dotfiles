{
  config,
  lib,
  ...
}:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    defaultKeymap = "emacs";

    localVariables = {
      PS1 = "%F{240}[%F{183}%n%f@%F{117}%m %F{169}%~%F{240}]%f$ ";
    };

    shellAliases = {
      ls = "ls --color=auto --group-directories-first";
      l = "ls";
      la = "ls -a";
      ll = "ls -l";
      ka = "killall -I -r";
      update = "doas nixos-rebuild switch --flake ~/.dotfiles";
      ip = "ip -color=auto";
      grep = "grep --color=auto";
      vs = "codium";
      s = "ssh";
      v = "vim";
      e = "hx";
      neofetch = "fastfetch";
    };
    
    history = {
      size = 5000;
      path = "${config.xdg.dataHome}/zsh/history";
    };

    initContent = lib.mkMerge [
      (lib.mkOrder 550 ''
        zstyle ":completion:*" matcher-list "" "m:{a-zA-Z}={A-Za-z}"
      '')
      ''
        bindkey "^[[1;5C" forward-word
        bindkey "^[[1;5D" backward-word
        bindkey "^H" backward-kill-word
        bindkey "5~" kill-word
        bindkey "^[[3~" delete-char
      ''
    ];
  };
} 