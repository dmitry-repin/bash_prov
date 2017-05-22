#!/bin/bash

is_package_installed nginx && systemctl stop nginx || true
