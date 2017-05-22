#!/bin/bash

uwsgi_installed && systemctl stop uwsgi-${PROJECT_NAME} || true
