{ writeShellApplication
, gnused
}:

# based off:
# https://xkcd.com/936/

# wordlist (forgive my potty mouth) derived from:
# https://github.com/gautesolheim/25000-syllabified-words-list

writeShellApplication {
  name = "pin-generator";
  runtimeInputs = [
    gnused
  ];
  text = ''
    RAND1=$((RANDOM % 1024 + 1))
    RAND2=$((RANDOM % 1024 + 1))

    WORD1=$(sed "$RAND1"'q;d' ${./wordlist.txt})
    WORD2=$(sed "$RAND2"'q;d' ${./wordlist.txt})

    printf '%s%s' "$WORD1" "$WORD2"
  '';
  meta = {
    description = "Generate pins with 20bits of entropy";
    mainProgram = "pin-generator";
  };
}
