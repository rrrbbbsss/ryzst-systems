{ ryzst }:

{
  default = {
    type = "app";
    program = "${ryzst.apps}/bin/ryzst";
  };
  burn-iso = {
    type = "app";
    program = "${ryzst.apps}/bin/burn-iso";
  };
  ryzst-installer = {
    type = "app";
    program = "${ryzst.apps}/bin/ryzst-installer";
  };
  yubikey-setup = {
    type = "app";
    program = "${ryzst.apps}/bin/yubikey-setup";
  };
  template-picker = {
    type = "app";
    program = "${ryzst.apps}/bin/template-picker";
  };
}

