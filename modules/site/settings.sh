#!/bin/bash

readonly WWW_PATH="/var/www/${PROJECT_NAME}"
if [[ $TARGET = $DEV ]]; then
  readonly PROJECT_PATH="/vagrant/${PROJECT_NAME}"
else
  readonly PROJECT_PATH="${WWW_PATH}/${PROJECT_NAME}"
fi
