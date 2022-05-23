#!/usr/bin/env bash

set -e

exec ansible-playbook --inventory=hosts.ini --limit=$1 deploy.yml
