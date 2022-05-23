#!/usr/bin/env bash

source $(dirname "$0")/services.sh

services $@

docker-compose stop $services
docker-compose rm --force $services

for service in $services
do

  if [ "$service" == "backup-director" ]
   then
     docker volume rm services_backup-director
  elif [ "$service" == "backup-storage" ]
    then
      docker volume rm services_backup-storage
  elif [ "$service" == "dns-internal" ]
   then
     cp ./docker/config/original-dns-internal-hosts                            \
       ./docker/config/dns-internal-hosts
     cp ./docker/config/original-dns-internal-resolv.conf                      \
       ./docker/config/dns-internal-resolv.conf
  fi

done

docker-compose --env-file ./deploy.env up $services
