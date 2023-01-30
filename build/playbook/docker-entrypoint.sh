# ------------------------------------------------------------------------------
# build/playbook/docker-entrypoint.sh
# ------------------------------------------------------------------------------

# This is the Docker ENTRYPOINT script for the playbook Docker Compose service.
# It provides a wrapper to the ansible-playbook command that translates command
# line arguments passed to the Docker Compose service into ansible-playbook
# options.

# The first command line argument is always present and is the name of the
# playbook to run, which is one of "services", "customer" or "home".
playbook=$1
shift

for arg in "$@"; do

  # The remaining args after the playbook name, which we've already dealt with,
  # consist of an optional (can be omitted) list of one or more services. If
  # services are provided they are used to limit what the playbook has to do
  # using the ansible-playbook --limit and --tags options. This optional list of
  # services is then followe by another optional (again, can be omitted) list of
  # one or more ansible-playbook options, which are to be passed directly to the
  # ansible-playbook command.

  case $arg in

    'backup'|'calendar'|'dns'|'dynamic_dns'|'mail'|'web')

      # The arg is a valid service name, so add it to the lists of "services"
      # and "tags". The first of those lists is separated by spaces and the
      # second is separated by commas.

      if [[ $services ]]; then
        services="$services $arg"
      else
        services=$arg
      fi

      shift

    ;;

    *)

      break

    ;;

  esac

done

source /environment/services-to-hosts.sh
services-to-hosts $services

cols=$(tput cols)
perl -e "print '-' x $cols, \"\n\""
echo "About to run the $playbook playbook in the $MYENV environment."
if [[ "$services" ]]; then
echo "I was passed this list of services \"$services\" to limit my actions to."
else
echo "I was not passed any list of services to limit my actions to."
fi
echo "I am going to act on this list of hosts \"$hosts\"."
if [[ "$@" ]]; then
echo "I was passed these ansible-playbook options \"$@\"."
fi
perl -e "print '-' x $cols, \"\n\""

export ANSIBLE_ROLES_PATH=/my-roles:/libraries-ansible

if [ "$services" ] && [ "$@" ]; then

  ansible-playbook --inventory /environment/inventory/hosts.ini \
    --limit `echo $hosts | tr ' ' ','` --tags=`echo $services | tr ' ' ','` \
    "$@" /environment/playbooks/$playbook/playbook.yml

elif [ "$services" ] && [ ! "$opts" ]; then

  ansible-playbook --inventory /environment/inventory/hosts.ini \
    --limit=`echo $hosts|tr ' ' ','` --tags=`echo $services | tr ' ' ','` \
    /environment/playbooks/$playbook/playbook.yml

elif [ ! "$services" ] && [ "$opts" ]; then

  ansible-playbook --inventory /environment/inventory/hosts.ini \
    "$@" /environment/playbooks/$playbook/playbook.yml

else

  ansible-playbook --inventory /environment/inventory/hosts.ini \
    /environment/playbooks/$playbook/playbook.yml

fi
