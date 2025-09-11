# development tools like compilers, build management, containerization, ...
args@{ config, lib, pkgs, ... }:
let
  cfg = config.local.devtools;
in
{
  options.local.devtools = {
    java.enable = lib.mkEnableOption "whether to enable java devtools";
    docker.enable = lib.mkEnableOption "whether to enable docker devtools";
    python.enable = lib.mkEnableOption "whether to enable python devtools";
    proton.enable = lib.mkEnableOption "whether to enable proton";
    nodejs.enable = lib.mkEnableOption "whether to enable nodejs devtools";
    ollama.enable = lib.mkEnableOption "whether to enable ollama";
  };

  config = {
    # python, proton, nodejs, ollama
    environment.systemPackages =
        lib.optionals cfg.python.enable [
          (pkgs.python3.withPackages (p: with p; [ virtualenv pygobject-stubs pip uv ]))
        ]
        ++ lib.optionals cfg.proton.enable [
          pkgs.protonup-qt
          pkgs.lutris
        ]
        ++ lib.optionals cfg.nodejs.enable [
          pkgs.nodejs_24
          pkgs.pnpm
          pkgs.yarn
        ]
        ++ lib.optionals cfg.ollama.enable [
          (pkgs.ollama.override {
            acceleration = "cuda";
          })
        ];

    # java
    programs.java = lib.mkIf cfg.java.enable {
      enable = true;
      package = pkgs.unstable.jdk;
    };

    # docker
    virtualisation.docker = lib.mkIf cfg.docker.enable {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
      daemon.settings = {
        data-root = "/data/docker";
      };
    };

    # ollama
    services.ollama = lib.mkIf cfg.ollama.enable {
      enable = true;
      acceleration = "cuda";
      host = "0.0.0.0";   
      port = 11434;
    };


    services.open-webui.enable = true;
  };
}
