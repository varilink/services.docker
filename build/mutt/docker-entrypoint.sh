# ------------------------------------------------------------------------------
# build/mutt/docker-entrypoint.sh
# ------------------------------------------------------------------------------

# Entrypoint script for mutt client. It requires two positional parameters:
# 1. username - username of the mail service user
# 2. connection - connection to the internal (office) or external network

set -e

# Set named variables to positional values for greater readability further down:
username=$1
connection=$2

if [[ $connection == 'external' ]]
then

	# We are simulating client connection external to the office network.
	# Update the client's /etc/resolv.conf to use simulated, ISP DNS service.
	cat <<- EOF > /etc/resolv.conf
	nameserver ${EXTERNAL_NAMESERVER}
	options ndots:0
	EOF

elif [[ $connection == 'internal' ]]
then

	# We are simulating client connection to the office network.
	# Update the client's /etc/resolv.conf to use our internal DNS service.
	cat <<- EOF > /etc/resolv.conf
	search ${HOME_DOMAIN}
	nameserver ${INTERNAL_NAMESERVER}
	options ndots:0
	EOF

fi

# Copy config file to use for this run to the mutt config location.
# Config files are provided for each combination of username and connection.
cp "/config/$username ($connection).sh" ~/.muttrc

# Replace the current shell with mutt
exec mutt
