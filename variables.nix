# config variables that are shared by all of my devices.
{
  # nixos and home-manager state version (see top of flake.nix for channel version)
  version = "25.05";
  # use --impure for flake-rebuild by default
  allowImpureByDefault = false;
  # username and displayname of only user
  username = "pyw0w";
  displayname = "PyW0W";
  # global git config
  git.name = "pyw0w";
  git.email = "myxi2002@gmail.com";
  
  ### nixos configurations for different devices
  # documentation for possible attributes and their meanings
  # in flake.nix near "mkNixosConfig = device@{"
  nixosConfigs = { mkNixosConfigs, inputs }: mkNixosConfigs [
    { internalName = "desktop"; }
    { internalName = "laptop";  }
  ];
}
