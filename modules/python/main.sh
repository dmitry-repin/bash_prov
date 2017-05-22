#!/bin/bash

main() {
  # pyenv setup
  [ -d "$PYENV_PATH" ] || \
    git clone https://github.com/pyenv/pyenv.git "$PYENV_PATH"

  # pyenv-virtualenvwrapper setup
  local pyenv_vew_path="${PYENV_PATH}/plugins/pyenv-virtualenvwrapper"
  [ -d "$pyenv_vew_path" ] || \
    git clone https://github.com/yyuu/pyenv-virtualenvwrapper.git "$pyenv_vew_path"

  # pyenv configuration
  local pyenvrc_path="/home/${WWW_USER}/.pyenvrc"
  if [ ! -f pyenvrc_path ]; then
    export PYENV_PATH 
    envsubst '$PYENV_PATH' < ./assets/.pyenvrc.tmpl > "$pyenvrc_path"
  fi
  chown $WWW_USER:$WWW_GROUP "$pyenvrc_path"
  local profile_line='. ~/.pyenvrc'
  local conf_file
  for conf_file in .profile .bashrc; do
	  local conf_path="/home/${WWW_USER}/${conf_file}"
	  grep -q -F "$profile_line" "$conf_path" || \
	    echo "$profile_line" >> "$conf_path"  
  done
  . "$pyenvrc_path"
  
  # Python setup
  if [ ! -d "$PYTHON_PATH" ]; then
    apt-get install -y build-essential curl libbz2-dev libfreetype6-dev \
      libjpeg8-dev liblcms2-dev libmysqlclient-dev libncurses5-dev \
      libncursesw5-dev libreadline-dev libsqlite3-dev libssl-dev libtiff5-dev \
      libwebp-dev libxml2-dev libxslt1-dev llvm make python3-dev tcl8.6-dev \
      tk8.6-dev tk-dev wget xz-utils zlib1g-dev
    pyenv install "$PYTHON_VERSION"
    rm "/home/${WWW_USER}/.wget-hsts"
  fi
  chown -R $WWW_USER:$WWW_GROUP "$PYENV_PATH"
  
  # Virtual environment setup
  if [ ! -d "$PROJECT_VE_PATH" ]; then
    sudo -i -u $WWW_USER bash -i -c "\
      pyenv shell ${PYTHON_VERSION};\
      pyenv virtualenvwrapper;\
      mkvirtualenv ${PROJECT_NAME}\
    "
  fi
  run_in_python_ve "pip install -q -r ${MODULE_PATH}/assets/requirements.txt"
}

main
