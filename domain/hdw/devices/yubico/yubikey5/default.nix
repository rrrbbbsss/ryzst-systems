{ pkgs, ... }:
{
  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];

  # TODO: make a proper module for opensc
  environment.etc."opensc.conf".text = ''
    app default {
      card_atr 3b:fd:13:00:00:81:31:fe:15:80:73:c0:21:c0:57:59:75:62:69:4b:65:79:40 {
        name = "Yubikey 5";
        driver = "PIV-II";
        flags = "keep_alive";
      }
    }
  '';
}
