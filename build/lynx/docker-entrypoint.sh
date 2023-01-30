set -e

cat << EOF > /etc/resolv.conf
search ${HOME_DOMAIN}
nameserver ${INTERNAL_NAMESERVER}
options ndots:0
EOF

exec lynx -accept_all_cookies $1
