{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  # Create games directory with proper Steam Library structure
  systemd.tmpfiles.rules = [
    "d /mnt/games 0755 pyw0w users - -"
    "d /mnt/games/SteamLibrary 0755 pyw0w users - -"
    "d /mnt/games/SteamLibrary/steamapps 0755 pyw0w users - -"
    "d /mnt/games/SteamLibrary/steamapps/common 0755 pyw0w users - -"
    "d /mnt/games/SteamLibrary/steamapps/downloading 0755 pyw0w users - -"
    "d /mnt/games/SteamLibrary/steamapps/workshop 0755 pyw0w users - -"
    "d /mnt/games/SteamLibrary/steamapps/compatdata 0755 pyw0w users - -"
    "d /mnt/games/SteamLibrary/steamapps/shadercache 0755 pyw0w users - -"
    "d /mnt/games/SteamLibrary/compatibilitytools.d 0755 pyw0w users - -"
    # Create symlink from home directory to games directory
    "L+ /home/pyw0w/Games - - - - /mnt/games"
  ];

  # Ensure Steam can write to the new library directory
  systemd.services.steam-library-setup = {
    description = "Setup Steam Library permissions and config";
    wantedBy = [ "multi-user.target" ];
    after = [ "local-fs.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "setup-steam-library" ''
        # Set correct ownership
        ${pkgs.coreutils}/bin/chown -R pyw0w:users /mnt/games
        
        # Create basic libraryfolder.vdf if it doesn't exist
        if [ ! -s /mnt/games/SteamLibrary/libraryfolder.vdf ]; then
          cat > /mnt/games/SteamLibrary/libraryfolder.vdf << 'EOF'
"LibraryFolders"
{
	"TimeNextStatsReport"		"0"
	"ContentStatsID"		"0"
}
EOF
          ${pkgs.coreutils}/bin/chown pyw0w:users /mnt/games/SteamLibrary/libraryfolder.vdf
        fi
      '';
      RemainAfterExit = true;
    };
  };
} 