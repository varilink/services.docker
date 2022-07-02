#!/usr/bin/env bash

set -e

if [[ $# -eq 0 ]]
then

  # No command line parameter was provided. This is the case when containers are
  # brought up for initial deployment to the via Ansible. The only service we
  # need at this point is SSH, so bring that up in the foreground.
  exec /usr/sbin/sshd -D

else

  # We don't run systemd in container so apt will not have created /run/bacula
  if [[ ! -d "/run/bacula" ]]
  then
    mkdir /run/bacula
    chown bacula:bacula /run/bacula
  fi
  bacula-fd

  # A command line parameter was provided. This is the case
  #, bring SSH up in the background and whatever
  # command is indicated by the command line parameter in the foreground.

  if [[ $1 != 'email-certificates' ]]
  then
    /usr/sbin/sshd
  fi

  if [[ $1 == "backup" ]]
  then

    bacula-sd

    /usr/share/bacula-director/make_mysql_tables                               \
      --host=database-internal                                                 \
      --user=bacula                                                            \
      --password=bacula                                                        \
      bacula

    exec gosu bacula bacula-dir -f

  elif [[ $1 == "calendar" ]]
  then

    exec radicale -f

  elif [[ $1 == "database" ]]
  then

    exec mysqld_safe

  elif [[ $1 == "dns" ]]
  then

    exec dnsmasq --no-daemon

  elif [[ $1 == "dynamic-dns" ]]
  then

    rsyslogd # start the syslog daemon
    cron # start the cron daemon
    exec tail -f /var/log/syslog # tail syslog to the Docker sysout

  elif [[ $1 == "email-external" ]]
  then

    exim4 -bd
    exec dovecot -F

  elif [[ $1 == 'email-internal' ]]
  then

    exim4 -bd
    /etc/init.d/fetchmail
    exec dovecot -F

  elif [[ $1 == "reverse-proxy" ]]
  then

    exec nginx -g "daemon off;"

  elif [[ $1 == "wordpress" ]]
  then

    source /etc/apache2/envvars
    exec apache2 -D FOREGROUND

  fi

fi
