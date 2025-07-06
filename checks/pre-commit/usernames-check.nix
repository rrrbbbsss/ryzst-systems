{ self, system }:
let
  # TODO: do better
  usernames-check-script = with self.instances.${system.string};
    writeShellApplication {
      name = "usernames-check";
      runtimeInputs = [
        coreutils-full
        findutils
        jq
      ];
      text = ''
        WORDLIST=${lib.removeSuffix "/sub" self}/lib/names/wordlist.json
        USERS=$(find ./idm/users -maxdepth 1 -mindepth 1 -type d -printf '%f\n')

        # shellcheck disable=SC2016
        xargs -I {} jq --exit-status --arg WORD {} '. | index($WORD)' "$WORDLIST" <<<"$USERS"
      '';
    };
  usernames-check = {
    enable = true;
    name = "Username check";
    entry = "${usernames-check-script}/bin/usernames-check";
    files = "idm/users";
    language = "system";
    pass_filenames = false;
  };
in
usernames-check
