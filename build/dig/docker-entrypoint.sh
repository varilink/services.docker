set -e

ipaddr=`hostname -I`

if [[ $ipaddr =~ ^10\.0\.0 ]]; then

  exec dig @$INTERNAL_NAMESERVER $@

elif [[ $ipaddr =~ ^10\.0\.1 ]]; then

  exec dig @$EXTERNAL_NAMESERVER $@

fi
