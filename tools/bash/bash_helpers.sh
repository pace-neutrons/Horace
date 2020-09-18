#!/usr/bin/env bash

function echo_and_run {
  echo "+ $1"
  eval "$1"
}

function run_in_dir {
  (cd "$2" && echo_and_run "$1")
}

function warning {
  echo -e "\e[33m$1\e[0m"
}
