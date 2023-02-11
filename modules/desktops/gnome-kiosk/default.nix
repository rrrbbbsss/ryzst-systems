{ config, pkgs, home-manager, lib, ... }:
{
  # Desktop
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
  fonts = {
    enableDefaultFonts = true;
    fonts = with pkgs; [
      dejavu_fonts
      nerdfonts
      font-awesome
      roboto
    ];
  };
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
  environment.systemPackages = with pkgs; [
    gnomeExtensions.dash-to-dock #desktop
  ];
}