{
  pkgs,
  ...
}:
{
  users.users.pyw0w.packages = with pkgs; [
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
  ];
} 