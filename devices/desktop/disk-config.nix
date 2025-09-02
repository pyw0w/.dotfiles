{
  disko.devices.disk = {
    # ОС-диск
    system = {
      type = "disk";
      device = "/dev/nvme0n1";
      content = {
        type = "gpt";
        partitions = {
          esp = {
            type = "EF00";
            size = "1G";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          root = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "/root" = {
                  mountpoint = "/";
                  swap.".swapfile".size = "8G";
                };
                "/home" = {
                  mountpoint = "/home";
                };
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = [ "noatime" ];
                };
              };
            };
          };
        };
      };
    };

    # NVMe-диск для данных (Ollama/Modules)
    ollama = {
      type = "disk";
      device = "/dev/nvme1n1";
      content = {
        type = "gpt";
        partitions = {
          data = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/data/ollama";
            };
          };
        };
      };
    };

    # Диск для игр
    games = {
      type = "disk";
      device = "/dev/sdd";
      content = {
        type = "gpt";
        partitions = {
          steam = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/games";
            };
          };
        };
      };
    };

    # Бэкапы: объединённые диски (LVM Volume Group)
    backup1 = {
      type = "disk";
      device = "/dev/sda";
      content = {
        type = "gpt";
        partitions = {
          part = {
            size = "100%";
            content = {
              type = "lvm_pv";
              vg = "backupvg";
            };
          };
        };
      };
    };

    backup2 = {
      type = "disk";
      device = "/dev/sdb";
      content = {
        type = "gpt";
        partitions = {
          part = {
            size = "100%";
            content = {
              type = "lvm_pv";
              vg = "backupvg";
            };
          };
        };
      };
    };

    backup3 = {
      type = "disk";
      device = "/dev/sdc";
      content = {
        type = "gpt";
        partitions = {
          part = {
            size = "100%";
            content = {
              type = "lvm_pv";
              vg = "backupvg";
            };
          };
        };
      };
    };
  };

  disko.devices.lvm_vg = {
    backupvg = {
      type = "lvm_vg";
      lvs = {
        data = {
          size = "100%FREE";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/backup";
          };
        };
      };
    };
  };
}
