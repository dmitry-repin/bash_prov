#!/bin/bash

readonly PROJECT_NAME='THE_PROJECT'

readonly REPO_PATH=$(readlink -f  "$(dirname "${BASH_SOURCE[0]}")/..")

readonly STAGES="settings common stop main start"
readonly MODULES="www-user python backup postgresql nodejs site uwsgi nginx"

readonly LOCK_FILE="/var/lock/.${PROJECT_NAME}.lock"
readonly LOCK_FD=42
readonly LOCK_TIMEOUT=300

readonly VAGRANT_USER_NAME='vagrant'
readonly VAGRANT_GROUP_NAME='vagrant'

readonly WWW_USER_NAME='www-data'
readonly WWW_GROUP_NAME='www-data'
