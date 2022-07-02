#!/usr/bin/env bash

set -e

if [[ "$1" == 'internet' ]]
then

	cat <<- 'EOF' > /etc/resolv.conf
	search varilink.co.uk
	nameserver 10.0.0.105
	EOF

	gosu $2 bash -c "cp /config/internet-$2.sh ~/.muttrc"

elif [[ "$1" == 'office' ]]
then

	cat <<- 'EOF' > /etc/resolv.conf
	search varilink.co.uk
	nameserver 10.0.0.106
	EOF

	gosu $2 bash -c "cp /config/office-$2.sh ~/.muttrc"

fi

gosu $2 mutt
