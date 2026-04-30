#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function sprout_cli_init () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local -A CFG=(
    [repo]='gh:mk-pmb/stro-seedling-2601-pmb'
    [branch]='master'
    [remote]='origin'
    [destdir]=//
    [autorun]='install.sh'
    )
  local KEY= VAL=
  for KEY in "${!CFG[@]}"; do
    eval 'VAL="$SPROUT_'"${KEY^^}"'"'
    [ -z "$VAL" ] || CFG["$KEY"]="$VAL"
  done
  while [ "$#" -ge 1 ]; do
    VAL="$1"; shift
    case "$VAL" in
      -x ) CFG[branch]='experimental';;
      [a-z]*=* ) CFG["${VAL%%=*}"]="${VAL#*=}";;
      * ) echo E: "Unsupported CLI argument: $VAL" >&2; return 4;;
    esac
  done
  CFG[repo]="${CFG[repo]/#gh:/'https://github.com/'}"
  case "${CFG[destdir]}" in
    // )
      VAL="${CFG[repo]}"
      VAL="${VAL%/}"
      VAL="${VAL##*/}"
      CFG[destdir]="$VAL";;
  esac
  cd -- "$HOME" || return $?

  local -p | sed -nre 's~\)\s*$~~; s~\s+$~~; s~^CFG=\(?\s*~D: config: ~p'

  git init -- "${CFG[destdir]}" || return $?$(
    echo E: "Failed to (re-)init git repo: ${CFG[destdir]}" >&2)
  cd -- "${CFG[destdir]}" || return $?$(
    echo E: "Failed to chdir to: ${CFG[destdir]}" >&2)
  git stash || return $?$(echo E: 'Failed to git stash' >&2)
  git remote add --force -- "${CFG[remote]}" "${CFG[repo]}" || return $?$(
    echo E: "Failed to add remote '${CFG[remote]}'" >&2)
  git fetch -- "${CFG[remote]}" || return $?$(
    echo E: "Failed to fetch remote '${CFG[remote]}'" >&2)
  git reset --hard -- "${CFG[remote]}/${CFG[branch]}" || return $?$(
    echo E: 'Failed to hard-reset!' >&2)

  echo D: 'Sprouted.'
}










sprout_cli_init "$@"; exit $?
