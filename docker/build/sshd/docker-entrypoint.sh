#!/usr/bin/env bash

set -e

if [[ $# -eq 0 ]]
then

  # No command line parameter was provided. This is the case when containers are
  # brought up for initial deployment to the via Ansible. The only service we
  # need at this point is SSH, so bring that up in the foreground.
  exec /usr/sbin/sshd -D

else

  # A command line parameter was provided. This is the case
  #, bring SSH up in the background and whatever
  # command is indicated by the command line parameter in the foreground.

  /usr/sbin/sshd -D &
  # We don't run systemd in container so apt will not have created /run/bacula
  if [[ ! -d "/run/bacula" ]]
  then
    mkdir /run/bacula
    chown bacula:bacula /run/bacula
  fi
  /usr/sbin/bacula-fd -f &

  if [[ $1 = "backup-director" ]]
  then

    /usr/share/bacula-director/make_mysql_tables                               \
      --host=services_database.services_default                                \
      --user=bacula                                                            \
      --password=bacula                                                        \
      bacula
    exec gosu bacula /usr/sbin/bacula-dir -f

  elif [[ $1 == "backup-storage" ]]
  then

    exec gosu bacula /usr/sbin/bacula-sd -f

  elif [[ $1 == "calendar" ]]
  then

    exec radicale -f

  elif [[ $1 == "database" ]]
  then

    exec /usr/bin/mysqld_safe

  elif [[ $1 == "dns-internal" ]]
  then

    exec dnsmasq -d

  elif [[ $1 == "email-external" ]]
  then

    /usr/sbin/exim4 -bd &
    exec /usr/sbin/dovecot -F

  elif [[ $1 == 'email-internal' ]]
  then

    /usr/sbin/exim4 -bd &
    exec /usr/sbin/dovecot -F

  elif [[ $1 == "reverse-proxy" ]]
  then

    exec nginx -g "daemon off;"

  elif [[ $1 == "wordpress" ]]
  then

    source /etc/apache2/envvars
    exec apache2 -D FOREGROUND

  fi

fi
