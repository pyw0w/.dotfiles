args@{ config, lib, pkgs, ... }:
let
	cfg = config.local.develnext;
in
{
	options.local.develnext = {
		enable = lib.mkEnableOption "whether to install DevelNext IDE";
	};

	config = lib.mkIf cfg.enable {
		environment.systemPackages = [ pkgs.local.develnext ];
	};
} 