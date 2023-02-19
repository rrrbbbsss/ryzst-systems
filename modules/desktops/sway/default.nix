{ config, pkgs, lib, home-manager, ... }:
{
  # Login Manager
  boot.kernelParams = [ "console=tty1" ];
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd 'zsh --login -c ${pkgs.sway}/bin/sway'";
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
  qt = {
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
}