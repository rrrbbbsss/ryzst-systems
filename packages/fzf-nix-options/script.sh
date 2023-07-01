#! /usr/bin/env bash

set -euo pipefail

function Error() {
    printf "Error: $1\n"
    exit 1
}

function Preview() {
  RESULT=$(jq --arg a $1 '.[$a]' $OPTION_FILE)
  NAME=$1
  DESCRIPTION_DOC="
   <xml xmlns:xlink=\"http://www.w3.org/1999/xlink\">
   <para>
   $(echo $RESULT | jq -r '.description')
   </para>
   </xml>"
  DESCRIPTION=$(echo $DESCRIPTION_DOC | pandoc -f docbook -t plain)
  TYPE=$(echo $RESULT | jq -r '.type')
  DEFAULT=$(echo $RESULT | jq -r '.default.text')
  EXAMPLE=$(echo $RESULT | jq -r '.example.text')
  printf "Name:\n$NAME\n\n"
  printf "Description:\n$DESCRIPTION\n\n"
  printf "Type:\n$TYPE\n\n"
  printf "Default:\n$DEFAULT\n\n"
  printf "Example:\n$EXAMPLE"
}


INPUT=${1:-}
if [[ "$INPUT" == "nixos" ]]; then
    OPTION_FILE=$NIXOS_OPTIONS
    PROMPT="NixOS"
elif [[ "$INPUT" == "home" ]]; then
    OPTION_FILE=$HOME_OPTIONS
    PROMPT="Home Manager"
else
    Error "please specify 'nixos' or 'home' options"
fi

export -f Preview
export OPTION_FILE

jq -r 'keys[]' $OPTION_FILE \
    | fzf --reverse \
	--prompt="$PROMPT Options> " \
	--preview-window=up,wrap \
	--preview='bash -c "Preview {}"' \
    | wl-copy --trim-newline

