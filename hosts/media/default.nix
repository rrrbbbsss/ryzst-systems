{ config, pkgs, lib, ... }:

{
  ##################
  ### BootLoader ###
  ##################
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.tmpOnTmpfs = true;
  boot.kernelParams = [ "console=tty1" ];


  ############
  ### Root ###
  ############
  users.mutableUsers = false;
  users.users.root.initialPassword = "*";

  ##################
  ### Networking ### 
  ##################
  networking.hostName = "media";
  networking.networkmanager.enable = true;

  ##############
  ### Locale ###
  ##############
  time.timeZone = "America/Chicago";
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

  ###############
  ### Desktop ###
  ###############
  services.xserver = {
    enable = true;
    displayManager = {
      gdm.enable = true;
      autoLogin = {
        enable = true;
        user = "media";
      };
    };
    desktopManager.gnome = {
      enable = true;
      extraGSettingsOverrides = ''
        [org.gnome.desktop.lockdown]
        disable-lock-screen = true
      '';
    };
  };
  environment.gnome.excludePackages = with pkgs; [
    gnome-photos
    gnome-tour
    gnome.cheese
    gnome.epiphany
    gnome.geary
    gnome.totem
    gnome.simple-scan
    gnome.gnome-calendar
    gnome.gnome-contacts
    gnome.gnome-music
  ];
  environment.variables = {
    GTK_THEME = "Adwaita:dark";
  };

  #############
  ### Fonts ###
  #############
  fonts = {
    enableDefaultFonts = true;
    fonts = with pkgs; [
      dejavu_fonts
      nerdfonts
      font-awesome
      roboto
    ];
  };

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

  ###########
  ### NIX ###
  ###########
  # general:
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      cores = 12;
    };
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';
  };
  # autoupgrades: todo...
  system.autoUpgrade = {
    enable = false;
    persistent = true;
    randomizedDelaySec = "30min";
    dates = "daily";
    allowReboot = false;
    flake = "github:rrrbbbsss/ryzst-systems";
  };
  # garbage:
  nix.gc = {
    automatic = true;
    persistent = true;
    randomizedDelaySec = "30min";
    dates = "weekly";
    options = ''
      --delete-older-than 30d;
    '';
  };
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

  #######################
  ### System Packages ###
  #######################
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    age
    gnomeExtensions.dash-to-dock #desktop
  ];

  ##################
  ### NTP client ###
  ##################
  networking.timeServers = [ "ntp.int.ryzst.net" ];

  ##################
  ### DNS client ###
  ##################
  networking.nameservers = [ "10.0.2.1" ];

  ##################
  ### VPN client ###
  ##################
  # todo

  ##################
  ### SSH server ###
  ##################
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    openFirewall = true;
  };

  ################
  ### Firewall ###
  ################
  networking.firewall = {
    enable = true;
  };

}
