#!/bin/bash

main() {
  local nodejs_version='6.10.3-1nodesource1~xenial1'
  if ! (is_package_installed nodejs && [[ $(get_package_version nodejs) = "$nodejs_version" ]]); then
    curl -sL https://deb.nodesource.com/setup_6.x | bash -
    ensure_package_installed nodejs "$nodejs_version"
  fi
}

main
