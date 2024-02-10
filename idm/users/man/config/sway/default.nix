{ config, ... }:
{
  imports = [ ./system.nix ];

  home-manager.users.${config.device.user} = { pkgs, ... }:
    {
      imports = [ ./home.nix ];
    };
}
