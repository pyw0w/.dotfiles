args@{ config, lib, pkgs, ... }:
{
  services.zerotierone = {
    enable = true;
    joinNetworks = [ "65228d8d6d3ca6c3" ];
  };
} 