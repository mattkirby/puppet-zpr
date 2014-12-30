#!/usr/bin/env bash

set -e

command=$SSH_ORIGINAL_COMMAND
base="`echo ${command} | awk '{ print $1 }'`"
args="`echo ${command} | cut -b 6-`"
sanitize_base="`echo ${command} | grep -E ";|&|\||authorized_keys|sudoers" &> /dev/null ; echo $?`"
sanitize_args="`echo ${args} | awk '{ print $1 }'`"

sanitize_base() {
  if [[ "$sanitize_base" == "0" ]]; then
    echo "Fail: Only rsync is available."
    exit 2
  fi
}

sanitize_args() {
  if [[ "$sanitize_args" != "rsync" ]]; then
    echo "Fail: Only rsync is supported for zpr"
    exit 3
  fi
}

check_and_run() {
  case "$base" in
    "sudo")
      sudo $args
      ;;
    *)
      echo "Fail: Command ${base} is not supported"
      exit 1
      ;;
  esac
}

main() {
  sanitize_base
  sanitize_args
  check_and_run
}

main
