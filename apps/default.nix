{ pkgs }:
with pkgs.ryzst;
{
  default = {
    type = "app";
    program = "${apps}/bin/ryzst";
  };
  burn-iso = {
    type = "app";
    program = "${apps}/bin/burn-iso";
  };
  ryzst-installer = {
    type = "app";
    program = "${apps}/bin/ryzst-installer";
  };
  yubikey-setup = {
    type = "app";
    program = "${apps}/bin/yubikey-setup";
  };
  template-picker = {
    type = "app";
    program = "${apps}/bin/template-picker";
  };
}

