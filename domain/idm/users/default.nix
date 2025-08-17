self:
let
  mkUsers = dir: with builtins;
    mapAttrs
      (n: v: {
        module = v;
        uid = self.lib.names.user.toUID n;
      } // {
        # TODO: redo...
        keys = {
          gpg = "${v}/pubkeys/gpg.pub";
          ssh = "${v}/pubkeys/ssh.pub";
          x509 = "${v}/pubkeys/x509.crt";
        };
      }
      // fromJSON (readFile "${dir}/${n}/registration.json"))
      (self.lib.getDirs dir);
in
mkUsers ./.
