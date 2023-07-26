# ------------------------------------------------------------------------------
# build/playbook/docker-entrypoint.sh
# ------------------------------------------------------------------------------

# This is the Docker ENTRYPOINT script for the playbook Docker Compose service.
# It provides a wrapper to the ansible-playbook command that translates command
# line arguments passed to the Docker Compose service into ansible-playbook
# options.

RED='\033[0;31m'
NC='\033[0m' # No Color

# The playbook Docker Compose service connects to the office network so it needs
# to know where to go in order to connect to hosts on the internt network.
ip route add 10.0.1.0/24 via 10.0.0.254

# The first command line argument is always present and is the name of the
# project to run a playbook for, which is one of "services", "customer" or
# "home".
if [ "$1" == 'services' ] \
|| [ "$1" == 'customer' ] \
|| [ "$1" == 'home'     ]; then

  project=$1
  echo "Project=$project"
  shift

else

  message='The first arg must be given as "services" or "customer" or "home"'
  echo -e "${RED}$message${NC}"
  exit 1

fi

if [ "$MYENV" == 'now'   ] \
|| [ "$MYENV" == 'to-be' ] \
|| [ "$MYENV" == 'distributed' ]; then

  echo "Environment=$MYENV"

  [ $(ls -A /environment/projects/$project/) ]                                 \
    && cp -r /environment/projects/$project/* /project/.

  if [ ! "$MYENV" == 'distributed' ]; then

    cp /playbooks/*.yml /project/.

  fi

else

  message='MYENV must be set to "now" or "to-be" or "distributed"'
  echo -e "${RED}$message${NC}"
  exit 1

fi

if [ "$1" ]; then

  playbook="$1"
  shift

  if [ ! -f "/project/$playbook" ]; then

    message='That playbook is not present in the project'
    echo -e "${RED}$message${NC}"
    exit 1

  fi

else

  message="The second arg must be given as one of the project's playbooks"
  echo -e "${RED}$message${NC}"
  exit 1

fi

for arg in "$@"; do

  # The remaining arguments start with an optional (can be omitted) list of one
  # or more services. If services are provided they are used to limit what the
  # playbook has to do using the ansible-playbook --limit and --tags options.

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

echo "Playbook $playbook for Project $project in Environment $MYENV"

if [[ "$services" ]]; then
echo "Passed Services \"$services\" to limit actions"
else
echo "Not passed any services to limit actions"
fi

echo "Will act on hosts \"$hosts\""

if [[ "$@" ]]; then
echo "Passed ansible-playbook options \"$@\""
fi

perl -e "print '-' x $cols, \"\n\""

export ANSIBLE_ROLES_PATH=/my-roles

if [ "$services" ] && [[ "$@" ]]; then

  ansible-playbook --inventory /environment/inventory/hosts.ini \
    --limit `echo $hosts | tr ' ' ','` \
    --tags=`echo $services | tr ' ' ','` \
    "$@" /project/$playbook

elif [ "$services" ] && [[ ! "$@" ]]; then

  ansible-playbook --inventory /environment/inventory/hosts.ini \
    --limit=`echo $hosts|tr ' ' ','` \
    --tags=`echo $services | tr ' ' ','` \
    /project/$playbook

elif [ ! "$services" ] && [[ "$@" ]]; then

  ansible-playbook --inventory /environment/inventory/hosts.ini \
    "$@" /project/$playbook

else

  ansible-playbook --inventory /environment/inventory/hosts.ini \
    /project/$playbook

fi
