set -e

cat << 'EOF' > /etc/resolv.conf
nameserver 10.0.0.105
options ndots:0
EOF

exec swaks --from root@other.com --to $1 --server mail-other
