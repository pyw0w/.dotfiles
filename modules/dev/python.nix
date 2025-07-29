{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Python
    python3
    python3Packages.pip
    pipx
    poetry
    python3Packages.virtualenv
    pipenv
    pyenv
    python3Packages.setuptools
    python3Packages.wheel
    
    # Python tools
    python3Packages.black
    python3Packages.flake8
    python3Packages.mypy
    python3Packages.pytest
  ];
}
