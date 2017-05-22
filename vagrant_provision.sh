#!/bin/bash

set -e

pushd /vagrant/provision
export DEBIAN_FRONTEND=noninteractive
./bootstrap.sh
./provision.sh dev
popd
