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

      if [ $services ]; then
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

echo "environment=${MYENV}"
echo "playbook=$playbook"
echo "services=$services"
echo "options=$opts"
echo "hosts=$hosts"

ANSIBLE_ROLES_PATH=/my-roles:/libraries-ansible

if [ "$services" ] && [ "$opts" ]; then

set -x

ansible-playbook --inventory /environment/inventory/hosts.ini \
--limit `echo $hosts | tr ' ' ','` --tags=`echo $services | tr ' ' ','` \
"$args" /environment/playbooks/$playbook/playbook.yml

elif [ "$services" ] && [ ! "$opts" ]; then

  ANSIBLE_ROLES_PATH=/my-roles:/libraries-ansible ansible-playbook \
    --inventory /environment/inventory/hosts.ini \
    --limit=`echo $hosts|tr ' ' ','` --tags=`echo $services|tr ' ' ','` \
    /environment/playbooks/$playbook/playbook.yml

elif [ ! "$services" ] && [ "$opts" ]; then

  ANSIBLE_ROLES_PATH=/my-roles:/libraries-ansible ansible-playbook \
    --inventory /environment/inventory/hosts.ini \
    $opts /environment/playbooks/$playbook/playbook.yml

else

  ANSIBLE_ROLES_PATH=/my-roles:/libraries-ansible ansible-playbook \
    --inventory /environment/inventory/hosts.ini \
    /environment/playbooks/$playbook/playbook.yml

fi
