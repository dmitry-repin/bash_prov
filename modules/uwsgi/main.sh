#!/bin/bash

main() {
  # uWSGI installation
  if ! uwsgi_installed; then
    apt-get install -y libpcre3 libpcre3-dev
    run_in_python_ve "pip install uWSGI==2.0.15"
    run_in_python_ve "pip install uwsgitop==0.10"
  fi
  
  # uWSGI configuration

  # Ensure /etc/uwsgi exists
  [ -d /etc/uwsgi ] || mkdir /etc/uwsgi

  # uwsgi.ini
  if [[ $TARGET = $DEV ]]; then
    local src_tmpl='./assets/uwsgi.ini.dev.tmpl'
  else
    local src_tmpl='./assets/uwsgi.ini.tmpl'
  fi
  local dest_path="/etc/uwsgi/${PROJECT_NAME}.ini"
  export WWW_USER
  export WWW_GROUP
  export PROJECT_VE_PATH
  export PROJECT_PATH
  export PROJECT_NAME
  local tmpl_values='$WWW_USER $WWW_GROUP $PROJECT_VE_PATH $PROJECT_PATH $PROJECT_NAME'
  envsubst "$tmpl_values" < "$src_tmpl" > "$dest_path"
  chmod 644 "$dest_path"

  # uwsgi-<project_name>.service
  local src_tmpl='./assets/uwsgi.service.tmpl'
  local dest_path="/etc/systemd/system/uwsgi-${PROJECT_NAME}.service"
  export WWW_USER
  export WWW_GROUP
  export PROJECT_NAME
  export PROJECT_VE_PATH
  local tmpl_values='$WWW_USER $WWW_GROUP $PROJECT_NAME $PROJECT_VE_PATH'
  envsubst "$tmpl_values" < "$src_tmpl" > "$dest_path"
  chmod 644 "$dest_path"
}

main
