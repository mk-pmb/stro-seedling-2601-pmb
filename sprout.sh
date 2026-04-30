#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function sprout_cli_init () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local -A CFG=(
    [repo]='gh:mk-pmb/stro-seedling-2601-pmb'
    [branch]='master'
    [remote]='origin'
    [destdir]='~/lib/{|repo|last-seg|}'
    [autorun]='exec ./install.sh'
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

  sprout_insert_destdir_vars || return $?

  local -p | sed -nre 's~\)\s*$~~; s~\s+$~~; s~^CFG=\(?\s*~D: config: ~p'
  cd -- "$HOME" || return $?
  git init -- "${CFG[destdir]}" || return $?$(
    echo E: "Failed to (re-)init git repo: ${CFG[destdir]}" >&2)
  cd -- "${CFG[destdir]}" || return $?$(
    echo E: "Failed to chdir to: ${CFG[destdir]}" >&2)
  if git status --porcelain | grep .; then
    git stash || return $?$(echo E: 'Failed to git stash' >&2)
  fi

  local RMT="${CFG[remote]}"
  git remote | grep -xFe "$RMT" && git remote rm "$RMT" || true
  git remote add -- "$RMT" "${CFG[repo]}" || return $?$(
    echo E: "Failed to add remote '${CFG[remote]}'" >&2)
  git fetch -- "$RMT" "${CFG[branch]}" || return $?$(
    echo E: "Failed to fetch remote '${CFG[remote]}'" >&2)
  git reset --hard "${CFG[remote]}/${CFG[branch]}" || return $?$(
    echo E: 'Failed to hard-reset!' >&2)

  VAL="${CFG[autorun]:-# (none)}"
  echo D: "Sprouted. Gonna eval the install command: $VAL"
  eval "$VAL" || return $?
}


function sprout_insert_destdir_vars () {
  local DEST="${CFG[destdir]}" KEY= OLD= VAL=

  case "$DEST" in
    '~' ) DEST="$HOME";;
    '~/'* ) DEST="$HOME${DEST:1}";;
  esac

  # Simple verbatim CFG insertions
  for KEY in "${!CFG[@]}"; do
    OLD="{|$KEY|}"
    VAL="${CFG[KEY]}"
    DEST="${DEST//"$OLD"/"$VAL"}"
  done

  # Simple verbatim environment insertions
  KEY='
    HOME
    HOSTNAME
    USER
    '
  for KEY in $KEY; do
    OLD="{|$KEY|}"
    eval 'VAL="$'"$KEY"'"'
    DEST="${DEST//"$OLD"/"$VAL"}"
  done

  # Repo URL last segment
  VAL="${CFG[repo]}"
  VAL="${VAL%%'#'*}"
  VAL="${VAL%%'?'*}"
  VAL="${VAL%/}"
  VAL="${VAL##*/}"
  DEST="${DEST//'{|repo|last-seg|}'/"$VAL"}"

  CFG[destdir]="$DEST"
}










sprout_cli_init "$@"; exit $?
