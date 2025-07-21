{ config, ... }:
{
  imports = [ ./system.nix ];

  home-manager.users.${config.device.user} = {
    imports = [ ./home.nix ];
  };
}
