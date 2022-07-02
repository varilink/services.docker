#!/usr/bin/env bash

set -e

if [[ ! $@ ]]; then

  echo 'The lookup scope, "external" or "internal" must be provided'

fi

scope=$1
shift

if [[ "$scope" == 'external' ]]; then

  exec dig @10.0.0.106 $@

elif [[ "$scope" == 'internal' ]]; then

  exec dig @10.0.0.107 $@

else

  echo 'The first parameter must be the lookup scope, "external" or "internal"'
  exit 1

fi
