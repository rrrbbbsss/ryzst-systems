# shellcheck shell=bash
# TODO: have a module build this script.

shopt -s nullglob globstar

DAYS="$1"

ROOT_DIR="/nix/var/nix/gcroots/auto"

REGEX='^\47\
((\\/nix\\/var\\/nix\\/)\
|(\\/home\\/[^\\/]*\\/\\.local\\/state\\/nix\\/profiles\\/)\
|(\\/home\\/[^\\/]*\\/\\.local\\/state\\/home-manager\\/gcroots\\/)\
|(\\/var\\/lib\\/laminar\\/roots\\/)\
)'

CURRENT=$(date '+%s')
SECONDS=$((DAYS * 86400))
EXPIRED=$((CURRENT - SECONDS))

# shellcheck disable=SC2016
SCRIPT='($4 < X) && ($3 !~ R) { print $1 }'

stat --format='%N %Y' "$ROOT_DIR"/* \
  | awk -v X="$EXPIRED" -v R="$REGEX" "$SCRIPT" \
  | xargs -I '{}' unlink '{}'
