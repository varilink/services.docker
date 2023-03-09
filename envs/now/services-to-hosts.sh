# ------------------------------------------------------------------------------
# envs/now/services-to-hosts.sh
# ------------------------------------------------------------------------------

function services-to-hosts {

  backup='dns-external hub'
  calendar='dns-external hub'
  dns='dns-external hub'
  dynamic_dns='dns-external gateway hub'
  mail='dns-external gateway hub prod1'
  web='dev1 dns-external gateway hub prod2'

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
