set -e

if [[ $1 == 'external' ]]
then

	# We are simulating client connection external to the office network.
	# Update the client's /etc/resolv.conf to use simulated, ISP DNS service.
	cat <<- EOF > /etc/resolv.conf
	nameserver ${EXTERNAL_NAMESERVER}
	options ndots:0
	EOF

  ip route add 10.0.0.0/24 via 10.0.1.254

elif [[ $1 == 'internal' ]]
then

	# We are simulating client connection to the office network.
	# Update the client's /etc/resolv.conf to use our internal DNS service.
	cat <<- EOF > /etc/resolv.conf
	search ${HOME_DOMAIN}
	nameserver ${INTERNAL_NAMESERVER}
	options ndots:0
	EOF

  ip route add 10.0.1.0/24 via 10.0.0.254

fi

sed -i 's/^http_access deny all$/http_access allow all/' /etc/squid/squid.conf

exec squid -N
