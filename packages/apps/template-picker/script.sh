#!/usr/bin/env bash

set -euo pipefail

function Error() {
    printf "Error: $1\n"
    exit 1
}

project=${1:-}
while [ -z "$project" ]; do
    printf "\n"
    read -p $'\e[1;34mEnter Project Name:\e[0m ' project
done

if [ -d "$project" ]; then
    Error "project folder already exists"
fi

flake="github:rrrbbbsss/ryzst-systems"
nix='nix --option experimental-features "nix-command flakes"'
templates=$(nix flake show "$flake" --json 2>/dev/null | jq '.templates')
choices=$(jq -r 'keys[]' <<<"$templates")
query="jq -r --arg a {} '.[\$a].description' <<< '$templates'"
text='###+++PROJECT+++###'

selection=$(fzf --reverse --prompt 'Select template > ' \
    --preview-window=bottom,wrap \
    --preview "$query" \
    <<<"$choices")

git init "$project"
pushd "$project"
nix flake init -t "$flake"\#"$selection"
git grep -Frl "$text" | xargs sed -i "s/$text/$project/g"
popd
