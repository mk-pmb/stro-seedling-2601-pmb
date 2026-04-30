#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function install_cli_init () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local SELFPATH="$(readlink -m -- "$BASH_SOURCE"/..)"
  cd -- "$SELFPATH" || return $?
  echo "D: $FUNCNAME stub in $PWD"
  mkdir --parents -- "$HOME"/bin || return $?
}










install_cli_init "$@"; exit $?
