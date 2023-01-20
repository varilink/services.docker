#!/usr/bin/env bash

set -e

cat << 'EOF' > /etc/resolv.conf
search varilink.co.uk
nameserver 10.0.0.106
EOF

cadaver http://caldav:5232
