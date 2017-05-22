#!/bin/bash

####################################
# Checks if uWSGI already installed
####################################
uwsgi_installed() {
  [ -f /etc/systemd/system/uwsgi-${PROJECT_NAME}.service ]
}
