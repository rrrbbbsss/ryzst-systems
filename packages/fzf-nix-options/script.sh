#! /usr/bin/env bash

function Preview() {
  RESULT=$(jq --arg a $1 '.[$a]' $OPTION_FILE)
  NAME=$1
  DESCRIPTION=$(echo $RESULT | jq -r '.description' | pandoc -f docbook -t plain)
  TYPE=$(echo $RESULT | jq -r '.type')
  DEFAULT=$(echo $RESULT | jq -r '.default.text')
  EXAMPLE=$(echo $RESULT | jq -r '.example.text')
  printf "Name:\n$NAME\n\n"
  printf "Description:\n$DESCRIPTION\n\n"
  printf "Type:\n$TYPE\n\n"
  printf "Default:\n$DEFAULT\n\n"
  printf "Example:\n$EXAMPLE"
}

if [[ $1 == "nixos" ]]; then
    OPTION_FILE=$NIXOS_OPTIONS
elif [[ $1 == "home" ]]; then
    OPTION_FILE=$HOME_OPTIONS
else
    printf "Error: please specify 'nixos' or 'home' options"
    exit 1
fi

export -f Preview
export OPTION_FILE

jq -r 'keys[]' $OPTION_FILE |
    fzf --reverse \
	--prompt="Home Manager Options> " \
	--preview-window=up,wrap \
	--preview='bash -c "Preview {}"'

