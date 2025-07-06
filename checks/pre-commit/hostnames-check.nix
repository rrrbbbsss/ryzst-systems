{ self, system }:
let
  # TODO: do better
  hostnames-check-script = with self.instances.${system.string};
    writeShellApplication {
      name = "hostnames-check";
      runtimeInputs = [
        coreutils-full
        findutils
        jq
      ];
      text = ''
        WORDLIST=${lib.removeSuffix "/sub" self}/lib/names/wordlist.json
        HOSTS=$(find ./hosts -maxdepth 1 -mindepth 1 -type d -printf '%f\n')
        WORD1=$(cut -d '-' -f 1 <<<"$HOSTS")
        WORD2=$(cut -d '-' -f 2 <<<"$HOSTS")

        # shellcheck disable=SC2016
        xargs -I {} jq --exit-status --arg WORD {} '. | index($WORD)' "$WORDLIST" <<<"$WORD1"
        # shellcheck disable=SC2016
        xargs -I {} jq --exit-status --arg WORD {} '. | index($WORD)' "$WORDLIST" <<<"$WORD2"
      '';
    };
  hostnames-check = {
    enable = true;
    name = "Hostname check";
    entry = "${hostnames-check-script}/bin/hostnames-check";
    files = "hosts/";
    language = "system";
    pass_filenames = false;
  };
in
hostnames-check
