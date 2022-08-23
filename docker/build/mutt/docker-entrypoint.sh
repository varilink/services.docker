#!/usr/bin/env bash

# This is the entrypoint script for our mutt client. It requires that three
# positional parameters are passed to it:
# 1. username - the username of the email user including the domain
# 2. connection - simulate connection to the office network or the Internet

# Set named variables from the positional values for greater readability below
username=$1
connection=$2

set -e

if [[ $connection == 'internet' ]]
then

	# We are simulating client connection over the Internet. Update the client's
	# /etc/resolv.conf to use our simulation of our ISP's DNS service.
	cat <<- 'EOF' > /etc/resolv.conf
	search varilink.co.uk
	nameserver 10.0.0.105
	options ndots:0
	EOF

elif [[ $connection == 'office' ]]
then

	# We are simulating client connection over the office networ. Update the
	# client's /etc/resolv.conf to use our simulation of our internal DNS service.
	cat <<- 'EOF' > /etc/resolv.conf
	search varilink.co.uk
	nameserver 10.0.0.106
	options ndots:0
	EOF

fi

# Copy the mutt configuration file that should be used for this run to the
# location that mutt will read configuration from. Configuration files are
# provided for every required combination of username and connection.
cp "/config/$username ($connection).sh" ~/.muttrc

# Replace the current shell with mutt
exec mutt
