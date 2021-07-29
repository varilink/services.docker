#!/usr/bin/env bash

# Commit containers to service specific images - see README.md for when and why
# to do this.

for SERVICE in                                                                 \
  database                                                                     \
  reverse_proxy                                                                \
  wordpress_host
do

  docker commit services_$SERVICE varilink/services/$SERVICE

done
