set -e

ip route add 10.0.1.0/24 via 10.0.0.254

if [[ ! $@ ]]; then

  echo 'The lookup scope, "external" or "internal" must be provided'

fi

scope=$1
shift

if [[ "$scope" == 'external' ]]; then

  exec dig @$EXTERNAL_NAMESERVER $@

elif [[ "$scope" == 'internal' ]]; then

  exec dig @$INTERNAL_NAMESERVER $@

else

  echo 'The first parameter must be the lookup scope, "external" or "internal"'
  exit 1

fi
