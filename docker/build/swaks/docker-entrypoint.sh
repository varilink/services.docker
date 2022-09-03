#!/usr/bin/env bash

set -e

cat << 'EOF' > /etc/resolv.conf
search varilink.co.uk
nameserver 10.0.0.105
options ndots:0
EOF

exec swaks --to $1 --server mail-other