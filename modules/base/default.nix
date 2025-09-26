args@{ lib, pkgs, variables, device, inputs, ... }:
{
  # other base modules can be enabled if desired
  imports = [
    ./gui
    ./gui/full.nix
    ./laptop.nix
  ];

  #########################################################
  ### most basic configuration every device should have ###
  #########################################################

  # self-explaining one-liners
  time.timeZone = "Asia/Yekaterinburg";
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = variables.version;
  nix.settings.experimental-features = [ "nix-command" "flakes" "pipe-operators" ];

  # Cachix configuration for faster builds
  nix.settings.substituters = [
    "https://cache.nixos.org"
    "https://nix-gaming.cachix.org"
    "https://nix-community.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];

  boot.loader = {
    efi.canTouchEfiVariables = true;
    timeout = 0; # only show when pressing keys during boot
    grub.enable = false;
    systemd-boot = {
      enable = true;
      configurationLimit = 20; # number of generations to show
    };
  };

  console = {
    earlySetup = true;
    keyMap = "us";
    colors = [
      "000000" "FC618D" "7BD88F" "FD9353" "5AA0E6" "948AE3" "5AD4E6" "F7F1FF"
      "99979B" "FB376F" "4ECA69" "FD721C" "2180DE" "7C6FDC" "37CBE1" "FFFFFF"
    ];
  };

  networking = {
    hostName = device.hostName;
    networkmanager.enable = true;
    firewall = {
      enable = true;

      # 7 Days to Die / Steam server ports:
      # Game server (UDP 26900 IN)
      # Steam communication (UDP 26901 IN)
      # Networking (LiteNetLib) (UDP 26902 IN)
      # Query port (Steam) (TCP 26900 IN)
      # Server list registration (UDP 27000-27050 OUT)

      allowedTCPPorts = [
        26900 # Query port (Steam)
      ];
      allowedUDPPorts = [
        26900 # Game server
        26901 # Steam communication
        26902 # Networking (LiteNetLib)
      ];
      allowedUDPPortRanges = [
        { from = 27000; to = 27050; } # Server list registration (OUT)
      ];
      # Note: NixOS firewall does not distinguish IN/OUT for allowed ports,
      # so this will allow UDP 27000-27050 both directions.
    };
  };

  i18n.defaultLocale  = "en_US.UTF-8";
  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "ru_RU.UTF-8/UTF-8"
  ];
  i18n.extraLocaleSettings = {
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT    = "en_US.UTF-8";
    LC_TELEPHONE      = "en_US.UTF-8";
    LC_MONETARY       = "en_US.UTF-8";
    LC_ADDRESS        = "en_US.UTF-8";
    LC_PAPER          = "en_US.UTF-8";
    LC_NAME           = "en_US.UTF-8";
  };

  # database for command-not-found in a declarative way without channels
  # https://blog.nobbz.dev/2023-02-27-nixos-flakes-command-not-found/
  environment.etc."programs.sqlite".source =
    (lib.getPkgs "programs-sqlite").programs-sqlite;
  programs.command-not-found.dbPath = "/etc/programs.sqlite";

  ### user account and groups
  # create new group with username
  users.groups.${variables.username} = {};
  # create user
  users.users.${variables.username} = {
    isNormalUser = true;
    description = variables.username;
    extraGroups = [ # add user to groups (if they exist)
      variables.username
      "users"
      "wheel"
      "networkmanager"
      "docker"
    ];
  };

  environment.systemPackages = with pkgs; [
    wget
    bash
    nano # text editor (replaces vim)
    jq # process json
    lsd # better ls
    bat # better cat
    fzf # fast fuzzy finder
    tldr # summarize man pages
    zoxide # better cd
    nomino # file renaming
    hyperfine # benchmarking tool
    numbat # cli calculator
    fortune # random quote
    librespeed-cli # speedtest
    nix-output-monitor # prettier output of nix commands
    cbonsai # ascii art bonsai
    asciiquarium-transparent # ascii art aquarium

    # osu! games from nix-gaming
    inputs.nix-gaming.packages.${pkgs.system}.osu-lazer-bin  # osu! lazer (binary version)
    inputs.nix-gaming.packages.${pkgs.system}.osu-stable     # osu! stable (wine version)
  ];

  local = {
    fish.enable = true;
    starship.enable = true;
    fastfetch.enable = true;
    devtools.python.enable = true;
    devtools.proton.enable = false;
    devtools.ollama.enable = true;
    devtools.nodejs.enable = false;
    devtools.docker.enable = false;
    archisteamfarm.enable = true;
  };

  # load dev environment from directory
  programs.direnv.enable = true;

  # run dynamically-linked binaries not meant for NixOS
  programs.nix-ld.enable = true;

  # ensure /bin/bash exists to make
  # #!/bin/bash script shebangs working
  system.activationScripts.binbash.text =
    "ln -sf /run/current-system/sw/bin/bash /bin/bash";

  # nix helper (prettier/better nix commands)
  programs.nh =  {
    enable = true;
    package = (lib.getPkgs "nh").nh;
    # automatic nix garbage collect
    clean = {
      enable = true;
      dates = lib.mkDefault "monthly";
      # always keep 2 generations
      extraArgs = "--keep 2";
    };
  };

  # more nix cache
  nix.settings = {
    extra-substituters = [ "https://nix-community.cachix.org" ];
    extra-trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
  };

  # disable hibernation
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    HandleLidSwitch=ignore
    HandleLidSwitchDocked=ignore
'';

  # for git authentication with ssh keys
  programs.ssh = {
    startAgent = true;
    # in order of preference
    hostKeyAlgorithms      = [ "ssh-ed25519" "ssh-rsa" ];
    pubkeyAcceptedKeyTypes = [ "ssh-ed25519" "ssh-rsa" ];
  };

  # some environment variables
  environment.variables = {
    EDITOR = "nano";
    # colorize man pages with bat
    MANPAGER = "sh -c 'col -bx | bat --language man --plain'";
    MANROFFOPT = "-c";
    # current device to use for flake-rebuild
    NIX_FLAKE_CURRENT_DEVICE = device.internalName;
    # use --impure for flake-rebuild by default (if configured)
    NIX_FLAKE_ALLOW_IMPURE_BY_DEFAULT = lib.mkIf variables.allowImpureByDefault 1;
  };

  ### manage stuff in /home/$USER/
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "hm-bak";
  home-manager.users.${variables.username} = { config, ... }:
  {
    home.stateVersion = variables.version;

    # i dont know what this does?
    programs.home-manager.enable = true;

    programs.git = {
      enable = true;
      userName = variables.git.name;
      userEmail = variables.git.email;
      extraConfig = {
        init.defaultBranch = "main";
        fetch.prune = true; # remove deleted remote branches locally
        pull.rebase = true; # rebase merge
      };
    };
  };
}
