# ------------------------------------------------------------------------------
# build/openssl/docker-entrypoint.sh
# ------------------------------------------------------------------------------

set -e

# The first command line argument is mandatory and must be the FQDN of the
# request; for example imap.customer.com, dev.home.com, etc.
fqdn="$1"
shift

# Use our own DNS service not the inbuilt Docker one.
cat <<- EOF > /etc/resolv.conf
search home.com
nameserver ${INTERNAL_NAMESERVER}
options ndots:0
EOF

# Extract the host name from the FQDN; for example:
# imap.customer.com -> imap
# dev.home.com -> dev
# etc.
IFS='.' read -a labels <<< "$fqdn"
for label in "${labels[@]}"; do
  host=$label
  break
done

case $host in

  'imap')

    port=993
    ;;

  'smtp')

    port=465
    ;;

  *)

    # If the host name is not imap or smtp then we assume that the request is
    # for a web service; for example www, dev, test or staging subdomains.

    port=443
    ;;

esac

openssl s_client -connect $fqdn:$port "$@"
