set -e

echo $2

ip_address=$(hostname -i)

if [[ $ip_address =~ ^10\.0\.1 ]]
then

	cat <<- EOF > /etc/resolv.conf
	domain ${HOME_DOMAIN}
	nameserver ${EXTERNAL_NAMESERVER}
	options ndots:0
	EOF

elif [[ $ip_address =~ ^10\.0\.0 ]]
then

	cat <<- EOF > /etc/resolv.conf
	domain ${HOME_DOMAIN}
	nameserver ${INTERNAL_NAMESERVER}
	options ndots:0
	EOF

fi

if [ "$2" = 'spam' ]
then

    exec swaks --from root@other.com --to $1 --server mail                     \
        --header 'Subject: GTUBE Test'                                         \
        --body                                                                 \
        'XJS*C4JDBQADN1.NSBN3*2IDNEN*GTUBE-STANDARD-ANTI-UBE-TEST-EMAIL*C.34X'

elif [ "$2" = 'virus' ]
then

    exec swaks --from root@other.com --to $1 --server mail                     \
        --header 'EICAR Anti-Virus Test File'                                  \
        --body 'The EICAR anti-virus test file is attached'                    \
        --attach-type text/plain --attach-name eicar.com                       \
        --attach                                                               \
        'X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*'

else

    exec swaks --from root@other.com --to $1 --server mail

fi
