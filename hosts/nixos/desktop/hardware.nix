{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/3d058b89-59ad-4b48-a8f5-b01bd2e415bf";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/45F0-E5F7";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  # Steam games disk - DEXP SSD C100 1TB
  fileSystems."/mnt/games" =
    { device = "/dev/disk/by-uuid/bb4a4238-79e8-4c20-a599-82327da76aab";
      fsType = "btrfs";
      options = [ "defaults" "noatime" "compress=zstd" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/4818894f-1557-4be9-a59a-a3352416e544"; } ];

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
