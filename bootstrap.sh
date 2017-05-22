#!/bin/bash

. ./common.sh

readonly MD5_FILE="/root/.${PROJECT_NAME}_bootstrap.md5"


#######
# main
#######
main() {
  # Checkout
  initial_check || exit 1
  check_md5 "${BASH_SOURCE[0]}" "$MD5_FILE" && exit 0

  # Acquire lock
  if ! lock; then
    echoerr 'Lock acquiring failed!'
    exit 1
  fi
  
  # Fix locale settings
  update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
  
  # Upgrade distro 
  apt-get update
  apt-get upgrade -y
  
  # Set supplementary packages
  apt-get install -y screen
  apt-get install -y git git-extras
  apt-get install -y joe mc vim
  apt-get clean
  
  # Script's MD5 sum saving
  save_md5 "${BASH_SOURCE[0]}" "$MD5_FILE"
}

main "$@"
