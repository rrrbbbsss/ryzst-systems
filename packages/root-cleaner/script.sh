# shellcheck shell=bash

shopt -s nullglob globstar

DAYS="$1"

ROOT_DIR="/nix/var/nix/gcroots/auto"

CURRENT=$(date '+%s')
SECONDS=$((DAYS * 86400))
EXPIRED=$((CURRENT - SECONDS))

# shellcheck disable=SC2016
SCRIPT='
($4 < X) &&
(($3 ~ /\/\.direnv\//) || ($3 ~ /\/result(-bin)?\47$/)) \
{ print $1 }
'

stat --format='%N %Y' "$ROOT_DIR"/* |
  awk -v X="$EXPIRED" "$SCRIPT" |
  xargs -I '{}' rm '{}'
