# ------------------------------------------------------------------------------
# envs/distributed/services-to-hosts.sh
# ------------------------------------------------------------------------------

function services-to-hosts {

  backup='backup-director backup-storage database-internal'
  backup="$backup dns-external dns-internal mail-internal mail-external"
  calendar='caldav dns-external dns-internal'
  dns='dns-external dns-internal'
  dynamic_dns='dns-external dns-internal dynamic-dns mail-internal'
  mail='dns-external dns-internal'
  mail="$mail mail-certificates mail-external mail-internal"
  web='database-external database-internal'
  web="$web reverse-proxy-external reverse-proxy-gateway reverse-proxy-internal"
  web="$web wordpress-external wordpress-internal"
  web="$web dns-external dns-internal"

  if [[ $# -eq 0 ]]
  then

    hosts="$backup $calendar $dns $dynamic_dns $mail $web"

  else

    for service in $@
    do

      if [[ 'backup calendar dns dynamic_dns mail web' =~ ( |^)$service( |$) ]]
      then

        # Concatenates the content of the variable whose name is $service to the
        # string $services.
        hosts="$hosts ${!service}"

      else

        # This function is called by scripts, the output of which is expected to
        # be piped into another shell. That's why echo is repeated in the output
        # of the echo command below, so that the other shell executes that
        # second echo.
        echo "echo \"I do not recognise $service as a valid composite service\""
        exit 1

      fi

    done

  fi

  hosts=`echo $hosts | xargs -n1 | sort | uniq | paste -sd " "`

}
