# shellcheck shell=bash

set -euo pipefail

flake="git+ssh://git@git.int.ryzst.net/domain"
system=$(nix eval --impure --raw --expr 'builtins.currentSystem')
apps=$(nix flake show "$flake" --json 2>/dev/null \
         | jq '.apps."'"$system"'" | del(.default)')
choices=$(jq -r 'keys[]' <<<"$apps")
selection=$(fzf --reverse --prompt 'Select App > ' <<<"$choices")

nix run "$flake"\#"$selection"
