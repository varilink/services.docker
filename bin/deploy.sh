#!/usr/bin/env bash

source $(dirname "$0")/services.sh

services $@

docker-compose stop $services
docker-compose rm --force $services

for service in $services
do

  if [ "$service" == "backup-director" ]
  then
    docker volume rm services_backup
  fi

done

docker-compose --env-file ./deploy.env up $services
