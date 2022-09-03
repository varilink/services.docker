#!/usr/bin/env bash

set -e

fqdn="$1"

cat <<- 'EOF' > /etc/resolv.conf
search home.com
nameserver 10.0.0.105
options ndots:0
EOF

IFS='.' read -a labels <<< "$fqdn"
for label in "${labels[@]}"; do
  host=$label
  break
done

case $host in

  imap)
    port=993
    ;;

  smtp)
    port=465
    ;;

  www)
    port=443
    ;;

esac

openssl s_client -connect $fqdn:$port -servername $fqdn |                      \
openssl x509 -noout -text
