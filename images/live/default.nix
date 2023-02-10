{ config, pkgs, options, lib, home-manager, ... }:
{
  ###############
  ### cd-base ###
  ###############
  # Adds terminus_font for people with HiDPI displays
  console.packages = options.console.packages.default ++ [ pkgs.terminus_font ];
  # ISO naming.
  isoImage.isoName = "live.iso";
  # EFI booting
  isoImage.makeEfiBootable = true;
  # USB booting
  isoImage.makeUsbBootable = true;
  # use faster compression to build faster
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";
  # Add Memtest86+ to the CD.
  boot.loader.grub.memtest86.enable = true;
  # An installation media cannot tolerate a host config defined file
  # system layout on a fresh machine, before it has been formatted.
  swapDevices = lib.mkImageMediaOverride [ ];
  fileSystems = lib.mkImageMediaOverride config.lib.isoFileSystems;

  ##################
  ### Networking ### 
  ##################
  networking.hostName = "live";
  networking.networkmanager.enable = true;

  ##############
  ### Locale ###
  ##############
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

  #####################
  ### Login Manager ###
  #####################
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd ${pkgs.sway}/bin/sway";
      };
    };
    vt = 7;
  };


  ###############
  ### Desktop ###
  ###############
  security.pam.services.swaylock = {
    text = "auth include login";
  };
  security.polkit.enable = true;

  #############
  ### Fonts ###
  #############
  fonts.fonts = with pkgs; [
    dejavu_fonts
    nerdfonts
    font-awesome
    roboto
  ];

  #############
  ### Sound ###
  #############
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # for cursor to show up with sway in vm
  environment.variables = {
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  #######################
  ### System Packages ###
  #######################
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    clinfo
    wireguard-tools
  ];

  ###########
  ### NIX ###
  ###########
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

}