#!/bin/bash

main() {
  # INSTALLATION

  local repo_params="deb http://nginx.org/packages/mainline/ubuntu/ $(lsb_release -cs) nginx"
  local repo_key_url='https://nginx.org/keys/nginx_signing.key'
  ensure_repo_exists nginx "$repo_params" "$repo_key_url"
  ensure_package_installed nginx "1.13.0-1~xenial"
  
  # CONFIGURATION
  
  # nginx.conf
  local conf_path='/etc/nginx/nginx.conf'
  [ -f "${conf_path}~" ] || cp "$conf_path" "${conf_path}~"
  sed "s/^user .*/user ${WWW_USER};/" "$conf_path" > "${conf_path}.new"
  mv -f "${conf_path}.new" "$conf_path"
  sed 's/^worker_processes .*/worker_processes  auto;/' "$conf_path" > "${conf_path}.new"
  mv -f "${conf_path}.new" "$conf_path"
  
  # delete default.conf
  rm -f /etc/nginx/conf.d/default.conf
  
  # <project>.conf
  local src_tmpl="./assets/${TARGET}.conf.tmpl"
  local dest_path="/etc/nginx/conf.d/${PROJECT_NAME}.conf"
  export PROJECT_NAME
  export SITE_URL
  local tmpl_values='$PROJECT_NAME $SITE_URL'
  envsubst "$tmpl_values" < "$src_tmpl" > "$dest_path"
  chmod 644 "$dest_path"
  
  # disable autostart
  systemctl disable nginx > /dev/null 2>&1
}

main
