{ config, pkgs, options, lib, modulesPath, ... }:
let
  username = config.device.user;
in
{
  imports = [
    (modulesPath + "/installer/cd-dvd/iso-image.nix")
    (modulesPath + "/profiles/base.nix")
    (modulesPath + "/profiles/all-hardware.nix")
    #todo: clean this up
    ../../idm/users/rrrbbbsss/config/zsh
    ../../modules/hardware/common/wifi
  ];

  device.user = "installer";
  os = {
    auth.enable = false;
    nix.enable = false;
  };
  networking.networkmanager.dns = lib.mkForce "default";

  nixpkgs.hostPlatform.system = "x86_64-linux";

  # Adds terminus_font for people with HiDPI displays
  console.packages = options.console.packages.default ++ [ pkgs.terminus_font ];
  # ISO naming.
  isoImage = {
    isoName = "installer.iso";
    volumeID = "ryzst-iso";
    makeEfiBootable = true;
    makeBiosBootable = true;
    makeUsbBootable = true;
    squashfsCompression = "gzip -Xcompression-level 1";
  };
  # Add Memtest86+ to the CD.
  boot.loader.grub.memtest86.enable = true;
  # An installation media cannot tolerate a host config defined file
  # system layout on a fresh machine, before it has been formatted.
  swapDevices = lib.mkImageMediaOverride [ ];
  fileSystems = lib.mkImageMediaOverride config.lib.isoFileSystems;

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  users.users = {
    ${username} = {
      isNormalUser = true;
      extraGroups = [ "wheel" "video" ];
      # no password
      initialHashedPassword = "";
    };
    root = {
      # no password
      initialHashedPassword = "";
    };
  };

  home-manager.users.${username} = { pkgs, ... }: {
    imports = [
      ../../idm/users/rrrbbbsss/config/alacritty
    ];
    programs.zsh.initExtra = ''
      [[ -v DISPLAY ]] && sudo ${pkgs.ryzst.apps}/bin/ryzst-installer
    '';
    home.stateVersion = "22.11";
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  hardware.opengl.enable = true;

  services.cage = {
    enable = true;
    program = "${pkgs.alacritty}/bin/alacritty";
    user = username;
    extraArguments = [ "-d" "-s" ];
  };

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      dejavu_fonts
    ];
  };

  environment.variables.GC_INITIAL_HEAP_SIZE = "1M";
  boot.kernel.sysctl."vm.overcommit_memory" = "1";
  environment.etc."systemd/pstore.conf".text = ''
    [PStore]
    Unlink=no
  '';
}
