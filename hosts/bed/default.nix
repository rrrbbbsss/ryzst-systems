{ config, pkgs, home-manager, lib, ... }:

{
  # BootLoader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true; # change this to false
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.tmpOnTmpfs = true;
  boot.kernelParams = [ "console=tty1" ];

  # Networking
  networking.hostName = builtins.baseNameOf ./.;

  # Login Manager
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd ${pkgs.sway}/bin/sway";
      };
    };
    vt = 7;
  };
  # Desktop
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
  # Fonts
  fonts = {
    enableDefaultFonts = true;
    fonts = with pkgs; [
      dejavu_fonts
      nerdfonts
      font-awesome
      roboto
    ];
  };
  # Sound
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

  # VMS
  virtualisation.libvirtd = {
    enable = true;
    qemu.runAsRoot = false;
    onShutdown = "shutdown";
  };

  # NFS
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
  environment.systemPackages = with pkgs; [
    nfs-utils
  ];

  # Printer
  services.printing = {
    enable = true;
  };
}