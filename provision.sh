#!/bin/bash

. ./common.sh

readonly MD5_FILE="/root/.${PROJECT_NAME}_provision.md5"

readonly TARGETS='dev stage prod'
readonly DEV='dev'
readonly STAGE='stage'
readonly PROD='prod'

###########################
# Prints usage information
#   Globals:
#     TARGETS
###########################
usage() {
  echoerr "Usage: $0 [-r backup_to_restore] <$(tr ' ' '|' <<< $TARGETS)>"
}


##########################
# Sets options values
#   Arguments:
#     $1 - variable name
#     $2 - variable value
#   Returns:
#     <variable>
##########################
set_option_value() {
  if [ -z "${!1}" ]; then
    eval $1="$2"
  else
    echoerr 'Invalid options!'
    usage
    return 1
  fi
}


###############################################################
# Verifies specified target against the list of allowed values
#   Globals:
#     TARGETS
#   Arguments:
#     $1 - target
#   Returns:
#     0 - check success
#     1 - check fail
###############################################################
verify_target() {
  if ! [[ "$1" =~ ^($(tr ' ' '|' <<< $TARGETS))$ ]]; then
    echoerr 'Wrong target! Choose one from the list:'
    local target
    for target in $TARGETS; do
      echoerr " - $target"
    done
    usage
    return 1
  fi
  return 0
}


#######
# main
#######
main() {
  # Checkout
  initial_check || exit 1
  
  # Get options
  local option
  while getopts :r: option; do
    case "$option" in
      r)
        set_option_value backup_to_restore "$OPTARG"
        if [ ! -d "$backup_to_restore" ]; then
          echoerr 'Wrong backup to restore directory!'
          exit 1
        fi
        readonly BACKUP_TO_RESTORE=$(readlink -f "$backup_to_restore")
        ;;
      *)
        echoerr 'Invalid options!'
        usage
        exit 1
        ;;
    esac
  done
  shift $(($OPTIND-1))
  verify_target $1 || exit 1
  readonly TARGET=$1
  
  # Acquire lock
  if ! lock; then
    echoerr 'Lock acquiring failed!'
    exit 1
  fi

  # Target-dependent settings
  if [[ $TARGET = $DEV ]]; then
    readonly WWW_USER=$VAGRANT_USER_NAME
    readonly WWW_GROUP=$VAGRANT_GROUP_NAME
  else
    readonly WWW_USER=$WWW_USER_NAME
    readonly WWW_GROUP=$WWW_GROUP_NAME
  fi
  readonly SUPPLEMENTARY_DIR="/home/${WWW_USER}/${PROJECT_NAME}/supplementary"

  # Modules installation
  local module
  local stage
  for stage in $STAGES; do
    for module in $MODULES; do
      MODULE_PATH="${REPO_PATH}/provision/modules/${module}"
      pushd "$MODULE_PATH" > /dev/null
      if [ -f "${stage}.sh" ]; then
        echo ''
        echo '==='
        echo "STARTING  STAGE  ${stage}  FOR  MODULE  ${module}"
        . "./${stage}.sh"
        echo "FINISHED  STAGE  ${stage}  FOR  MODULE  ${module}"
        echo '==='
        echo ''
      fi
      popd > /dev/null
    done
  done
  apt-get clean
}

main "$@"
