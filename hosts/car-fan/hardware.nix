{ config, lib, pkgs, ... }:

{
  imports = [
    ../../modules/hardware/common/gpu/intel
    ../../modules/hardware/common/wifi
    ../../modules/hardware/devices/lenovo/x230
    ../../modules/hardware/devices/yubico/yubikey5
  ];

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi = {
        efiSysMountPoint = "/boot";
        canTouchEfiVariables = true;
      };
    };
    initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "nvme"
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];
    #zfs
    initrd.systemd.enable = true;
    initrd.supportedFilesystems = [ "zfs" ];
  };

  #zfs
  networking.hostId = lib.mkForce "79468924";
  boot = {
    kernelParams = [ "nohibernate" ];
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    zfs.forceImportRoot = false;
    zfs.devNodes = "/dev/disk/by-partuuid";
    supportedFilesystems = [ "zfs" ];
  };

  services.zfs = {
    autoScrub = {
      enable = true;
      interval = "weekly";
    };
    trim = {
      enable = true;
      interval = "weekly";
    };
  };

  #https://discourse.nixos.org/t/impermanence-vs-systemd-initrd-w-tpm-unlocking/25167/2
  boot.initrd.systemd.services.rollback = {
    description = "Rollback ZFS datasets to a pristine state";
    wantedBy = [
      "initrd.target"
    ];
    after = [
      "zfs-import-tank.service"
    ];
    before = [
      "sysroot.mount"
    ];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = ''
      ${pkgs.zfs}/bin/zfs rollback -r "tank/local/root@blank"
    '';
  };

  disko.devices = {
    disk = {
      sda = {
        device = "/dev/sda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              label = "ESP";
              type = "EF00";
              size = "512M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountOptions = [ "umask=0077" ];
                mountpoint = "/boot";
              };
            };
            TANK = {
              label = "TANK";
              size = "100%";
              content = {
                type = "zfs";
                pool = "tank";
              };
            };
          };
        };
      };
    };
    zpool = {
      tank = {
        type = "zpool";
        rootFsOptions = {
          compression = "on";
          acltype = "posix";
          relatime = "on";
          canmount = "off";
          devices = "off";
          mountpoint = "none";
        };

        datasets = {
          "local" = {
            type = "zfs_fs";
          };
          "local/root" = {
            type = "zfs_fs";
            options = {
              mountpoint = "legacy";
              xattr = "sa";
            };
            mountpoint = "/";
            postCreateHook = "zfs snapshot tank/local/root@blank";
          };
          "local/nix" = {
            type = "zfs_fs";
            options = {
              atime = "off";
              mountpoint = "legacy";
            };
            mountpoint = "/nix";
          };
          # TODO: move mointpoint
          "local/secrets" = {
            type = "zfs_fs";
            options = {
              quota = "128M";
              mountpoint = "legacy";
            };
            mountpoint = "/secrets";
          };
          "local/logs" = {
            type = "zfs_fs";
            options = {
              xattr = "sa";
              quota = "10G";
              mountpoint = "legacy";
            };
            mountpoint = "/var/log";
          };

          # TODO: move mointpoint
          "persist" = {
            type = "zfs_fs";
            options = {
              xattr = "sa";
              mountpoint = "legacy";
            };
            mountpoint = "/persist";
          };
        };
      };
    };
  };

  fileSystems."/persist" = {
    neededForBoot = true;
  };

  # TODO: update installtion script (secrets):

  # TODO: break apart
  #impermanence
  environment.persistence."/persist" = {
    directories = [
      "/var/lib/iwd"
      "/var/lib/systemd/timers"
      "/var/lib/systemd/coredump"
      "/var/lib/nixos"
      # TODO: comb through home...
      "/home"
    ];
    files = [
      "/etc/machine-id"
      "/etc/adjtime"
    ];
  };
}
