{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.swappy;
  settingsIni = { Default = cfg.settings; };
in
{
  options.programs.swappy = {
    enable = mkEnableOption "swappy snapshot editor tool";

    package = mkOption {
      type = types.package;
      default = pkgs.swappy;
      defaultText = literalExpression "pkgs.swappy";
      description = "swappy package to install";
    };

    settings = mkOption {
      type = with types; attrsOf (oneOf [ bool int str ]);
      default = { };
      example = literalExpression ''
        {
          save_dir = "$HOME/Desktop";
          line_size = 5;
          text_size = 20;
          text_font = "sans-serif";
          early_exit = false;
        }
      '';
      description = ''
        Configuration written to
        <filename>$XDG_CONFIG_HOME/swappy/config</filename>.
        See <literal>swappy(1)</literal> man page for supported values.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    xdg.configFile."swappy/config" = mkIf (cfg.settings != { }) {
      text = generators.toINI { } settingsIni;
    };
  };
}
