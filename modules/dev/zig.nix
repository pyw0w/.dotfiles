{ pkgs, ... }:

let
  cDevTools = with pkgs; [
    gcc
    clang
    cmake
    ninja
    pkg-config
    gnumake
    autoconf
    automake
    libtool
  ];
  debugTools = with pkgs; [
    gdb
    lldb
    valgrind
    strace
    ltrace
    perf-tools
  ];
in
{
  home.packages = with pkgs; [
    zig
  ] ++ cDevTools ++ debugTools;

  home.sessionVariables = {
    CC = "gcc";
    CXX = "g++";
  };
}
