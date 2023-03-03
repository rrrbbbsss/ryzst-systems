{ config, lib, pkgs, modulesPath, ... }:

{
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi = {
        efiSysMountPoint = "/boot/efi";
        canTouchEfiVariables = true;
      };
    };
    tmpOnTmpfs = true;
    kernelParams = [ "console=tty1" ];
    initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  };

  fileSystems = {
    "/boot/efi" = {
      label = "BOOT";
      fsType = "vfat";
    };
    "/" = {
      label = "ROOT";
      fsType = "ext4";
    };
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  # CPU
  hardware.enableRedistributableFirmware = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = true;
  boot.kernelModules = [ "kvm-intel" ];

  # yubikey
  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # keyboard
  services.kanata = {
    enable = true;
    keyboards = {
      lenovo = {
        devices = [ "/dev/input/by-path/platform-i8042-serio-0-event-kbd" ];
        port = null;
        config = ''
          				(defsrc
            esc  mute vold volu                          prnt slck pause ins del  home pgup
                 f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11   f12      end  pgdn
            grv  1    2    3    4    5    6    7    8    9    0    -     =        bspc
            tab  q    w    e    r    t    y    u    i    o    p    [     ]        ret
            caps a    s    d    f    g    h    j    k    l    ;    '     \
            lsft 102d z    x    c    v    b    n    m    ,    .    /              rsft
            wkup lctl lmet lalt           spc            ralt cmps rctl      bck  up   fwd
                                                                             left down rght
          )

          (defalias
            hyp (multi lsft lmet lctl lalt)
            ;; Control that does 'spc' on tap
            csp (tap-hold-release 200 200 spc lctl)
            ;; "Hyper" that does 'esc' on tap
            ehp (tap-hold-release 200 200 esc @hyp))

          (deflayer qwerty
            caps mute vold volu                          prnt slck pause ins del  home pgup
                 f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11   f12      end  pgdn
            grv  1    2    3    4    5    6    7    8    9    0    -     =        bspc
            tab  q    w    e    r    t    y    u    i    o    p    [     ]        ret
            @ehp a    s    d    f    g    h    j    k    l    ;    '     \
            lsft _    z    x    c    v    b    n    m    ,    .    /              rsft
            _    lctl lmet lalt          @csp            ralt rmet rctl      bck  up   fwd
                                                                             left down rght
          )
          			'';
      };
    };
  };

}
