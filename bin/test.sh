#!/usr/bin/env bash

#-------------------------------------------------------------------------------
# Commit the containers based on the varilink/services image and configured by
# the Ansible deploy.yml playbook to service specific images. For a
# description of when and how to use this script, see the heading "Committing
# Service Specific Images" in the README for this repository:
# https://github.com/varilink/services-docker/blob/main/README.md
#-------------------------------------------------------------------------------

source $(dirname "$0")/services.sh

services $@

for service in $services
do

  echo "Commit for $service"
  docker commit services_$service varilink/services/$service

done

docker-compose up $services
