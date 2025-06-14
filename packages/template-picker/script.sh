# shellcheck shell=bash

function Error() {
  printf 'Error: %s\n' "$1"
  exit 1
}

project=${1:-}
while [ -z "$project" ]; do
  printf "\n"
  read -rp $'\e[1;34mEnter Project Name:\e[0m ' project
done

if [ -d "$project" ]; then
  Error "project folder already exists"
fi

# shellcheck disable=SC2154
choices=$(ls "$templates")
text='###+++PROJECT+++###'

selection=$(fzf --reverse --prompt 'Select template > ' <<<"$choices")

cp -r "$templates/$selection" "$project"
chmod -R u+w "$project" # eww...
git -C "$project" init
git -C "$project" add -A
git -C "$project" grep -Frl "$text" |
  xargs -I '{}' sed -i "s/$text/$project/g" "$project"/'{}'

# TODO: bird law...
