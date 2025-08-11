# shellcheck shell=bash

# this is junky but whatever.
# can make it better later.
shopt -s nullglob globstar

FLAKE="$1"

PREFIX=/run/current-system/specialisation
SPECIALS=("$PREFIX"/*)
SPECIALS=("${SPECIALS[@]#"$PREFIX"/}")
SPECIALS+=(default)

SPECIAL=$(printf '%s\n' "${SPECIALS[@]}" \
            | fzf --reverse --prompt='specials > ')

[[ -n $SPECIAL ]] || exit

if [[ $SPECIAL == "default" ]]; then
  sudo nixos-rebuild test --flake "$FLAKE"
else
  sudo nixos-rebuild test --specialisation "$SPECIAL" --flake "$FLAKE"
fi
