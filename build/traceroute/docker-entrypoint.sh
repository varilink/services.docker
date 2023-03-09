set -e

# Get the IP address via the hostname command.
ipaddr=`hostname -I`

if [[ $ipaddr =~ ^10\.0\.0 ]]; then

  # This host is on our simulation of the office network. Add a route to hosts
  # that are on our simulation of the Internet.

  ip route add 10.0.1.0/24 via 10.0.0.254

elif [[ $ipaddr =~ ^10\.0\.1 ]]; then

  # This host is on our simulation of the Internet. Add a route to hosts that
  # are on our simulation of the office network.

  ip route add 10.0.0.0/24 via 10.0.1.254

fi

exec traceroute "$@"
