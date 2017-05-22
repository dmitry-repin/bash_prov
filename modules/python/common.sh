#!/bin/bash

#####################################################
# Runs a command in the project's Python environment
#   Arguments:
#     $1 - command to run
#####################################################
run_in_python_ve() {
  sudo -i -u $WWW_USER bash -i -c "\
    pyenv shell ${PYTHON_VERSION};\
    pyenv virtualenvwrapper;\
    workon ${PROJECT_NAME};\
    $1
  "
}
