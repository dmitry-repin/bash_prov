#!/bin/bash

main() {
  # Ensure www path exists
  [ -d "$WWW_PATH" ] || mkdir -p "$WWW_PATH"
  
  # Ensure media path exists
  local media_path="${WWW_PATH}/media"
  [ -d "$media_path" ] || mkdir -p "$media_path"

  chown -R $WWW_USER:$WWW_GROUP "$WWW_PATH"
  
  # Ensure log file exists
  local log_dir_path="/var/log/${PROJECT_NAME}"
  [ -d "$log_dir_path" ] || mkdir -p "$log_dir_path"
  local log_file_path="${log_dir_path}/${PROJECT_NAME}"
  [ -f "$log_file_path" ] || : > "$log_file_path"
  chown -R $WWW_USER:$WWW_GROUP "$log_dir_path"
  
  # Copy the Django project into $WWW_PATH for non-dev environments
  if [[ $TARGET != $DEV ]]; then
    rsync -rlptc --delete "${REPO_PATH}/${PROJECT_NAME}" "${PROJECT_PATH}"
    chown -R $WWW_USER:$WWW_GROUP "$PROJECT_PATH"
  fi
  
  # Set a proper environment for the Django project settings
  pushd "${PROJECT_PATH}/${PROJECT_NAME}/settings" > /dev/null
  ln -s -f -T "./${TARGET}" env
  popd > /dev/null
  
  # Copy supplementary files into the Django project
  if [[ $TARGET != $DEV ]]; then
    local local_py_source="${SUPPLEMENTARY_DIR}/django/local.py"
    local local_py_dest="${PROJECT_PATH}/${PROJECT_NAME}/settings/local.py"
    cp -f "$local_py_source" "$local_py_dest"
    chown $WWW_USER:$WWW_GROUP "$local_py_dest"
  fi
  
  # Create DB
  if [[ $TARGET = $DEV ]]; then
	  if ! (sudo -u postgres psql -l | grep "$PROJECT_NAME" -q); then
	    local request_tmpl='./assets/createdb.sql.tmpl'
	    export PROJECT_NAME
	    envsubst '$PROJECT_NAME' < "$request_tmpl" | sudo -u postgres psql
	  fi
  else
    #TODO: Implement DB creating for the prod and stage environments
    true
  fi
  
  # Restore from backup
  #TODO: Add restoration from backup 

  # Run migrations
  run_in_python_ve "python ${PROJECT_PATH}/manage.py migrate --noinput"

  # Create default superuser for the dev environment
  if [[ $TARGET = $DEV ]]; then
    admin_req="SELECT username FROM auth_user where username='admin';"
    (sudo -u postgres psql -d "$PROJECT_NAME" -t -c "$admin_req" | grep admin -q) || \
      sudo -i -u postgres psql "$PROJECT_NAME" < ./assets/createsuperuser.sql
  fi
  
  # yarn setup
  local repo_params='deb https://dl.yarnpkg.com/debian/ stable main'
  local repo_key_url='https://dl.yarnpkg.com/debian/pubkey.gpg'
  ensure_repo_exists yarn "$repo_params" "$repo_key_url"
  ensure_package_installed yarn 0.24.5-1
  
  # Build static
  local project_static="${PROJECT_PATH}/${PROJECT_NAME}/static"

  if [[ $TARGET = $DEV ]]; then
    local tmp_static="/tmp/${PROJECT_NAME}/static"
    rm -rf "${tmp_static}"
    mkdir -p "${tmp_static}"
    rsync -rlt --exclude="node_modules/" "${project_static}/source" "$tmp_static"
    chown -R $WWW_USER:$WWW_GROUP "/tmp/${PROJECT_NAME}"
    sudo -i -u $WWW_USER bash -i -c "\
      cd ${tmp_static}/source;\
      yarn;\
      yarn run build --production;\
    "
    local resource
    for resource in css js svg manifest.json; do
      rm -rf "${project_static}/${resource}"
      mv "${tmp_static}/${resource}" "${project_static}"
    done
    rm -rf "$tmp_static"
    
  else
    sudo -i -u $WWW_USER bash -i -c "\
      cd ${project_static}/static/source;\
      yarn;\
      yarn run build --production;\
    "
    rm -rf "${project_static}/source"
  fi
  
  # Collect static
  if [[ $TARGET != $DEV ]]; then
    local static_path="${WWW_PATH}/static"
    [ -d "$static_path" ] || mkdir -p "$static_path"
    run_in_python_ve "python ${PROJECT_PATH}/manage.py collectstatic --noinput"
    chown -R $WWW_USER:$WWW_GROUP "$WWW_PATH"
  fi
}

main
