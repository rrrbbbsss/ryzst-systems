{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.device.ir;
  mkWav = codePath:
    # TODO: don't use runCommand due to cross
    pkgs.runCommand "ir.wav" { } ''
      ${pkgs.ryzst.lirc_rawcode2wav}/bin/lirc_rawcode2wav ${codePath} $out
    '';
in
{
  options.device.ir = {
    code = mkOption {
      type = with types; attrsOf (attrsOf path);
      default = { };
      description = "attribute set of paths to ir codes";
      example = literalExpression ''{
        power = ./path-to-power.ir;
        volume-up = ./path-to-volume-up.ir;
        volume-down = ./path-to-volume-down.ir;
      }'';
    };
    wav = mkOption {
      type = with types; attrsOf (attrsOf path);
      default = { };
      description = "attribute set of paths to ir wavs";
    };
  };
  config = {
    device.ir.wav = foldlAttrs
      (acc: name: value: {
        "${name}" = foldlAttrs
          (a: n: v: { "${n}" = mkWav v; } // a)
          { }
          value;
      } // acc)
      { }
      cfg.code;
  };
}
