{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.media-powermenu;
in
{
  options.programs.media-powermenu = {
    enable = mkEnableOption "swappy snapshot editor tool";

    package = mkPackageOption pkgs.ryzst "media-powermenu" { };

    configDir = mkOption {
      type = types.path;
      example = literalExpression "./media-powermenu-config-dir";
      description = ''
        The directory that gets symlinked to
        {file}`$XDG_CONFIG_HOME/eww`.
      '';
    };

    buttons = mkOption {
      type = with types; attrsOf str;
      # TODO: example
      description = ''
        The commands to run for buttons.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    xdg.configFile."media-powermenu".source = cfg.configDir;
  };
}
