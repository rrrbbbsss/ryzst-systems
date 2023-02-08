{ config, pkgs, home-manager, lib, ... }:

{
  ##################
  ### BootLoader ###
  ##################
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true; # change this to false
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.tmpOnTmpfs = true;
  boot.kernelParams = [ "console=tty1" ];


  ##################
  ### Networking ### 
  ##################
  networking.hostName = "bed";
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
  programs.dconf.enable = true;
  programs.xwayland.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
  };
  # use dark themes
  environment.variables = {
    GTK_THEME = "Adwaita:dark";
  };
  qt5 = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
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
    flake = "git+ssh://git@git.int.ryzst.net:/srv/git/pub/ryzst-systems?=main";
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
  ];

  ###########
  ### VMS ###
  ###########
  virtualisation.libvirtd = {
    enable = true;
    qemu.runAsRoot = false;
    onShutdown = "shutdown";
  };

  ##################
  ### NFS client ###
  ##################
  services.rpcbind.enable = true;
  systemd.mounts = [{
    type = "nfs";
    mountConfig = {
      Options = "noatime";
    };
    what = "nfs.int.ryzst.net:/";
    where = "/nfs";
  }];
  systemd.automounts = [{
    wantedBy = [ "multi-user.target" ];
    automountConfig = {
      TimeoutIdleSec = "600";
    };
    where = "/nfs";
  }];

  ##################
  ### NTP client ###
  ##################
  networking.timeServers = [ "ntp.int.ryzst.net" ];

  ##################
  ### DNS client ###
  ##################
  networking.nameservers = [ "10.0.2.1" ];

  ######################
  ### Printer client ###
  ######################
  services.printing = {
    enable = true;
  };

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
