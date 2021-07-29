#!/usr/bin/env bash

set -e

if [[ $# -eq 0 ]]
then

  # No command line parameter provided, bring SSH up in the foreground.
  exec /usr/sbin/sshd -D

else

  # Command line parameter provided, bring SSH up in the background and whatever
  # command is indicated by the command line parameter in the foreground.

  /usr/sbin/sshd -D &

  if [[ $1 == "database" ]]
  then

    exec mysqld_safe

  elif [[ $1 == "reverse_proxy" ]]
  then

    exec nginx -g "daemon off;"

  elif [[ $1 == "wordpress_host" ]]
  then

    source /etc/apache2/envvars
    exec apache2 -D FOREGROUND

  fi

fi
