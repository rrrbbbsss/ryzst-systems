{ config, lib, pkgs, modulesPath, ... }:

{
  # BootLoader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true; # change this to false
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.tmpOnTmpfs = true;
  boot.kernelParams = [ "console=tty1" ];



  hardware.enableRedistributableFirmware = lib.mkDefault true;
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];

  #############
  ### DISKS ###
  #############
  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/925b4d7c-09ac-4da9-9dc1-46a2b04b06b2";
      fsType = "ext4";
    };

  fileSystems."/boot/efi" =
    {
      device = "/dev/disk/by-uuid/035B-BE66";
      fsType = "vfat";
    };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/7fb4c73f-04f2-434b-83cf-3eab9b829e31"; }];

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  ############
  ### NICS ###
  ############
  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp3s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp4s0.useDHCP = lib.mkDefault true;

  ###########
  ### CPU ###
  ###########
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = true;
  boot.kernelModules = [ "kvm-amd" ];

  ###############
  ### Display ###
  ###############
  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;

  ###############
  ### yubikey ###
  ###############
  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];

  ###########
  ### GPU ###
  ###########
  boot.initrd.kernelModules = [ "amdgpu" ];
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      amdvlk
      glxinfo
      rocm-opencl-icd
      rocm-opencl-runtime
      mesa.drivers
    ];
  };
  environment.variables.AMD_VULKAN_ICD = lib.mkDefault "RADV";
  environment.systemPackages = with pkgs; [
    rocminfo
    # IR controller
    v4l-utils
  ];

  ################
  ### keyboard ###
  ################
  services.kanata = {
    enable = true;
    keyboards = {
      lenovo = {
        devices = [ "/dev/input/by-id/usb-Lenovo_TrackPoint_Keyboard_II-event-kbd" ];
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
