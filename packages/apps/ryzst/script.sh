#!/usr/bin/env bash

set -euo pipefail

flake="github:rrrbbbsss/ryzst-systems"
nix='nix --option experimental-features "nix-command flakes"'
system=$(nix eval --impure --raw --expr 'builtins.currentSystem')
apps=$(nix flake show "$flake" --json 2>/dev/null \
	   | jq '.apps."'$system'" | del(.default)')
choices=$(jq -r 'keys[]' <<< "$apps")
selection=$(fzf --reverse --prompt 'Select App > ' <<< "$choices")

nix run "$flake"\#"$selection"
