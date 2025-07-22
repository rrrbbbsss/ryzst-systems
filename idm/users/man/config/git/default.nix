{ config, ... }:
{
  home-manager.users.${config.device.user} = { pkgs, ... }: {
    # TODO: don't hardcode
    programs.git = {
      enable = true;
      userName = "Royce Strange";
      userEmail = "rrrbbbsss@ryzst.net";
      signing = {
        key = "6DB578354383FF64797A2D7E985AC6F0827B273C";
        signByDefault = true;
      };
      extraConfig = {
        init = {
          defaultBranch = "main";
        };
      };
    };
    programs.direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
      };
    };
  };
}
