# Provides the function services that translates business services into Docker
# Compose services. This function can be passed zero or more business services
# from this list:
# - backup
# - calendar
# - dns_internal
# - dynamic_dns
# - email
# - web
# It sets a variable "services" to a sorted list of either all the Docker
# Compose (if no business services were passed) or all the Docker Compose
# services associated with the passed business services.

function services {

  # Docker Compose services that combine to deliver the backup business service.
  backup='database backup-director backup-storage'
  # Docker Compose services that combine to deliver the email business service.
  email='email-external email-internal'
  # Docker Compose services that combine to deliver the web business service.
  web='database reverse-proxy wordpress'
  # Docker Compose services that deliver a business service by themselves.
  # These are mapped one-to-one with a business service with the same name but
  # with underscores in place of any hyphens used in the Docker Compose
  # service's name.
  other='calendar database dns-internal dynamic-dns'

  if [[ $# -eq 0 ]]
  then

    # No parameters were provided so return ALL Docker Compose services.
    services="$backup $email $web $other"

  else

    # One or more business services were provided so loop through them.
    for service in $@
    do

      if [[ 'backup email web' =~ ( |^)$service( |$) ]]
      then

        # The business service is one of backup, email or web.
        # Append the multiple Docker Compose services that combine to deliver
        # that business service to the output.
        services="$services ${!service}"

      elif [[ `echo "$other" | tr '-' '_'` =~ ( |^)$service( |$) ]]
      then

        # The business service is in the "other" list.
        # Append the single, associated Docker Compose service to the list,
        # remembering to translate underscores in the business service name to
        # hyphens in the Docker Compose service name.
        services="$services `echo "$service" | tr '_' '-'`"

      else

        # We were passed a business service name that we do not recognise, so
        # exit with an error response.
        exit 1

      fi

    done

  fi

  # Remove any duplicates from the list of Docker Compose services and sort them
  # alphabetically.
  services=`echo $services | xargs -n1 | sort | uniq`

}
