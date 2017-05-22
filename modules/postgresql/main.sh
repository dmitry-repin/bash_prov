#!/bin/bash

main() {
  if [[ $TARGET = $DEV ]]; then
    ensure_package_installed postgresql
    ensure_package_installed postgresql-contrib
    ensure_package_installed postgresql-server-dev-all
      
  else
    ensure_package_installed postgresql-client
  fi
}

main
