#!/usr/bin/env bash

#https://git.zx2c4.com/password-store/tree/contrib/dmenu/passmenu
shopt -s nullglob globstar

GPG_TTY=$(tty)
prefix=${PASSWORD_STORE_DIR-~/.password-store}
password_files=( "$prefix"/**/*.gpg )
password_files=( "${password_files[@]#"$prefix"/}" )
password_files=( "${password_files[@]%.gpg}" )
password=$(printf '%s\n' "${password_files[@]}" | fzf --reverse --prompt='pass > ')

[[ -n $password ]] || exit

setsid -w pass -c "$password" >/dev/null 