# disk config using disko
# https://github.com/nix-community/disko
{
  disko.devices.disk = {
    # operating system disk
    nixos = {
      type = "disk";
      device = "/dev/nvme1n1"; # newer ssd
      content = {
        type = "gpt";
        partitions = {
          # efi system partition
          esp = {
            type = "EF00";
            size = "1G";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          main = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ]; # override existing partition
              subvolumes = {
                "/main" = {
                  mountpoint = "/";
                  swap.".swapfile".size = "8G";
                };
                "/home" = {
                  mountpoint = "/home";
                };
                "/nix" = {
                  mountpoint = "/nix";
                  # don't save last access time
                  mountOptions = [ "noatime" ];
                };
              };
            };
          };
        };
      };
    };
  };
}
