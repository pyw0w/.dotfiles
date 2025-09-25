# for OpenTabletDriver
args@{ config, lib, pkgs, ... }:
lib.mkModule "opentabletdriver" config {
  hardware.opentabletdriver.enable = true;
}
