{ config, lib, pkgs, ... }:

{
  imports = [
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
  networking.hostId = "79468924";
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
  #boot.initrd.systemd.services.rollback = {
  #  description = "Rollback ZFS datasets to a pristine state";
  #  wantedBy = [
  #    "initrd.target"
  #  ];
  #  after = [
  #    "zfs-import-tank.service"
  #  ];
  #  before = [
  #    "sysroot.mount"
  #  ];
  #  unitConfig.DefaultDependencies = "no";
  #  serviceConfig.Type = "oneshot";
  #  script = ''
  #    ${pkgs.zfs}/bin/zfs rollback -r tank/local/root@blank"
  #  '';
  #};

  disko.devices = {
    disk = {
      sda = {
        device = "/dev/sda";
        type = "disk";
        content = {
          type = "table";
          format = "gpt";
          partitions = [
            {
              name = "ESP";
              start = "0";
              end = "128MiB";
              bootable = true;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            }
            {
              name = "TANK";
              start = "128MiB";
              end = "100%";
              part-type = "primary";
              bootable = true;
              content = {
                type = "zfs";
                pool = "tank";
              };
            }
          ];
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
        mountRoot = "/mnt";

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
          "local/secrets" = {
            type = "zfs_fs";
            options = {
              mountpoint = "legacy";
            };
            mountpoint = "/secrets";
          };
          "local/reserve" = {
            type = "zfs_fs";
            options = {
              refreservation = "20G";
              refquota = "20G";
            };
          };

          "persist" = {
            type = "zfs_fs";
            options = {
              xattr = "sa";
              mountpoint = "/legacy";
            };
            mountpoint = "/persist";
          };
        };
      };
    };
  };
}
