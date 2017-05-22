#!/bin/bash

set -e

export PATH='/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin'

export LC_ALL='en_US.UTF-8'


. ./settings.sh


######################################
# Redirects echo to stderr
#   Arguments:
#     $@ - echo's options and strings
######################################
echoerr() {
  echo "$@" 1>&2
}


###################
# Acquires lock
#   Globals:
#     LOCK_FILE
#     LOCK_FD
#     LOCK_TIMEOUT
###################
lock() {
  eval "exec $LOCK_FD>$LOCK_FILE"
  flock -n $LOCK_FD && return 0
  echoerr "Couldn't acquire lock."
  echoerr "Going to try again in $LOCK_TIMEOUT seconds maximum."
  flock -w $LOCK_TIMEOUT $LOCK_FD && return 0 || return 1
}


######################################################
# Performs initial checkout before the script was run
#   Returns:
#     0 - checkout success
#     1 - checkout fail
######################################################
initial_check() {
  # root user checkout
  (( $UID != 0 )) && echoerr 'This script must be run as root!' && return 1
  
  # OS checkout
  local os_check
  os_check() {
    local id=$(lsb_release -is)
    local release=$(lsb_release -rs)
    [[ $id = Ubuntu && $release = 16.04 ]] && return 0 || return 1
  }

  if os_check; then
    return 0
  else
    echoerr 'Unknown OS!'
    return 1
  fi
}


###################################
# Calculates MD5 sum of the script
#   Arguments:
#     $1 - path to the script
#   Returns:
#     stdout - md5 sum
###################################
get_md5() {
  echo $(md5sum "$1" | awk '{print $1}')
}


#####################################################################
# Checks MD5 sum of the script
#   Arguments:
#     $1 - path to the script
#     $2 - path to the file with MD5 sum
#   Returns:
#     0 - current checksum and the sum stored in $MD5_FILE are equal  
#     1 - either file $MD5_FILE is absent or checksums are different
#####################################################################
check_md5() {
  local script_path="$1"
  local md5_file="$2"
  [ -f "$md5_file" ] && [[ $(get_md5 "$script_path") = $(cat "$md5_file") ]] && return 0
  return 1
}


#########################################
# Saves MD5 sum of the script
#   Arguments:
#     $1 - path to the script
#     $2 - path to the file with MD5 sum
#########################################
save_md5() {
  local script_path="$1"
  local md5_file="$2"
  echo $(get_md5 "$script_path") > "$md5_file"
}


#####################################
# Checks if the package is installed
#   Arguments:
#     $1 - name of the package
#   Returns:
#     0 - package is installed
#     1 - package isn't installed
#####################################
is_package_installed() {
  dpkg -l "$1" 2> /dev/null | egrep ^.i. > /dev/null
}


#################################################
# Prints version number of the installed package
#   Arguments:
#     $1 - name of the package
#   Returns:
#     0 - package is installed
#     1 - package isn't installed
#################################################
get_package_version() {
  local package_name="$1"

  is_package_installed "$package_name" && \
    dpkg -s "$package_name" | grep "Version: " | cut -d' ' -f2
}


#####################################################
# Ensures the package of proper version is installed
#   Arguments:
#     $1 - name of the package
#     $2 - version number of the package (optional)
#   Returns:
#     0 - package was installed successfully
#     1 - package installation failed
#####################################################
ensure_package_installed() {
  local package_name="$1"
  local package_version="$2"

  if is_package_installed "$package_name"; then
    if [ -z "$package_version" ]; then
      return 0
    else
      if [[ $(get_package_version "$package_name") = "$package_version" ]]; then
        return 0
      else
        apt-get purge -y "$package_name"
      fi
    fi
  fi
  if [ -z "$package_version" ]; then
    apt-get install -y "$package_name"
  else
    apt-get install -y "$package_name"="$package_version"
  fi
}


######################################################
# Ensures that repo exists and si properly configured
#   Arguments:
#     $1 - name of the repo
#     $2 - repo's URL and parameters
#     $3 - repo's APT key URL
######################################################
ensure_repo_exists() {
  local repo_name="$1"
  local repo_params="$2"
  local repo_key_url="$3"

  local repo_file="/etc/apt/sources.list.d/${repo_name}.list"
  if ! egrep "^${repo_params}$" "$repo_file" > /dev/null 2>&1; then
    curl -sS "$repo_key_url" | apt-key add -
    echo "$repo_params" > "$repo_file"
    apt-get update
  fi
}
