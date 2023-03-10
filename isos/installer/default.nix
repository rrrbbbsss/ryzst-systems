{ config, pkgs, options, lib, home-manager, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/cd-dvd/iso-image.nix")
    (modulesPath + "/profiles/base.nix")
    (modulesPath + "/profiles/all-hardware.nix")
  ];

  # Adds terminus_font for people with HiDPI displays
  console.packages = options.console.packages.default ++ [ pkgs.terminus_font ];
  # ISO naming.
  isoImage = {
    isoName = "installer.iso";
    volumeID = "ryzst-iso";
    makeEfiBootable = true;
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

  # Networking
  networking.networkmanager.enable = true;

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    clinfo
    wireguard-tools
    ryzst.cli
  ];

  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';
  };
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

  users.users = {
    installer = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "video" ];
      # no password
      initialHashedPassword = "";
    };
    root = {
      # no password
      initialHashedPassword = "";
    };
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  services.getty.autologinUser = "installer";
  programs.bash.loginShellInit = ''
    sudo ryzst install system > output
  '';

  environment.variables.GC_INITIAL_HEAP_SIZE = "1M";
  boot.kernel.sysctl."vm.overcommit_memory" = "1";
  environment.etc."systemd/pstore.conf".text = ''
    [PStore]
    Unlink=no
  '';
}
