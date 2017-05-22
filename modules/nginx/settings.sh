#!/bin/bash

if [[ $TARGET = $PROD ]]; then
  readonly SITE_URL='THE_PROJECT.com'
else
  readonly SITE_URL="${TARGET}.THE_PROJECT.com"
fi
