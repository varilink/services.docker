# ------------------------------------------------------------------------------
# build/playbook/docker-entrypoint.sh
# ------------------------------------------------------------------------------

# This is the Docker ENTRYPOINT script for the playbook Docker Compose service.
# It provides a wrapper to the ansible-playbook command that translates command
# line arguments passed to the Docker Compose service into ansible-playbook
# options.

# ------

# ------------------------
# 1. Do some initial setup
# ------------------------

# Colour settings to enable us to echo error messages in red font.
RED='\033[0;31m'
NC='\033[0m' # No Color (NC)

# The playbook Docker Compose service connects to the office network so it needs
# to know where to go in order to connect to hosts on the internet network.
ip route add 10.0.1.0/24 via 10.0.0.254

# -----------------------------------
# 2. Validate the environment setting
# -----------------------------------

# The $MYENV environment variable must be set to the name of one of the
# supported test environments, which are "now", "to-be" and "distributed".

if [ "$MYENV" == 'now'   ] \
|| [ "$MYENV" == 'to-be' ] \
|| [ "$MYENV" == 'distributed' ]; then

  echo "Environment=$MYENV"

else

  message='MYENV must be set to "now" or "to-be" or "distributed"'
  echo -e "${RED}$message${NC}"
  exit 1

fi

# ------------------------------------------
# 3. Determine if this is a project playbook
# ------------------------------------------

# If the first command line argument is either "customer" or "home" then that
# signals that the playbook we're going to execute is a project playbook for
# either the "customer" or "home" project. If the first argumement is not one of
# "customer" or "home" then we are expecting to execute a non-project specific,
# "services" playbook.

if [ "$1" == 'customer' ] || [ "$1" == 'home'     ]; then

  project=$1
  echo "Project=$project"
  shift

fi

# -----------
# 4. Playbook
# -----------

# The next command line argument must always be provided and be the name of the
# the playbook that is to be run.

if [ "$1" ]; then

  # Capture and report the name of the playbook provided.

  playbook="$1"
  shift
  echo "Playbook=$playbook"

  if [ -n "$project" ]; then

    # We've been asked to execute a project specific playbook.

    if [ ! -f "/env/$project/$playbook" ]; then

      # The playbook requested is not present in the environment so report an
      # error and exit.

      message='That playbook is not present in the project for this environment'
      echo -e "${RED}$message${NC}"
      exit 1

    fi

  else

    # We've been asked to execute a non-project specific playbook.

    if [ ! -f "/env/$playbook" ]; then

      # The playbook requested is not present in the environment so report an
      # error and exit.

      message='That playbook is not present in this environment'
      echo -e "${RED}$message${NC}"
      exit 1

    fi

  fi

else

  # No playbook name provided, report error and exit.

  message="You must provide the file name for the playbook to execute"
  echo -e "${RED}$message${NC}"
  exit 1

fi

# -----------
# 5. Services
# -----------

# The remaining arguments are optional and combine zero or more service names
# followed by zero or more ansible-playbook options. We examine the arguments
# starting from the beginning. To begin with, any argument that is a string
# without a `-` or `--` prefix that matches one of the supported service names
# is added to a list of services in scope and removed as an argument. The list
# of services is used to restrict the hosts and tasks in the playbook using the
# the ansible-playbook `--limit` and `--tags` options.
#
# Providing a list of services in this way is only useful for playbooks that use
# tags to enable you to restrict their scope to one or more services; for
# example `install-services.yml`. Other playbooks are inherently more focussed
# in the scope of their action and so do not use tags. For those playbooks you
# can still specify `--limit` directly as an argument.

for arg in "$@"; do

  # Try to match the argument to a service name.

  case $arg in

    'backup'|\
    'calendar'|\
    'dns'|\
    'dynamic_dns'|\
    'fileshare'|\
    'mail'|\
    'monitor'|\
    'wordpress')

      # We have found a service name, so add it to the list of services and
      # remove it from the arguments.

      if [[ $services ]]; then
        services="$services $arg"
      else
        services=$arg
      fi

      shift

    ;;

    *)

      # We have encountered an argument that isn't a service name, so stop
      # matching arguments to service names.

      break

    ;;

  esac

done

if [[ "$services" ]]; then
  echo "Passed Services \"$services\" to limit actions"
else
  echo "Not passed any services to limit actions"
fi

# -------------------
# 6. Playbook options
# -------------------

# The arguments that remain after service names have been processed, i.e.
# starting with the first argument that is not a service name match, are passed
# directly to the ansible-playbook command. These can include any option
# supported by the ansible-playbook command.

if [[ "$@" ]]; then
  echo "Passed ansible-playbook options \"$@\""
fi

# --------
# 7. Hosts
# --------

# Use the `services-to-hosts.sh` script for this environment to set the hosts
# variable to a list of the hosts that must be in scope for this playbook run.

source /env/services-to-hosts.sh
services-to-hosts $services

echo "Will act on hosts \"$hosts\""

# ---------------------
# 8. Playbook execution
# ---------------------

# Output a horizontal rule to separate the reporting of setup above from what
# will be reported by the ansible-playbook command as it is running.

cols=$(tput cols)
perl -e "print '-' x $cols, \"\n\""

# Set the roles path so that the wrapper roles that are specific to testing in a
# Docker container environment are used instead of the roles in the "Libraries -
# Ansible Roles" repository. The wrapper roles then use the roles in the
# "Libraries - Ansible Roles" repository by referencing their full path within
# the containers.

export ANSIBLE_ROLES_PATH=/my-roles

# Start building the command to execute.

command='ansible-playbook --inventory /env/inventory/hosts.ini'

if [  "$services"  ]; then

  # We were passed a list of services to limit our scope. Translate this to the
  # required --limit and --tags options and add them to the command.

  limit=`echo $hosts | tr ' ' ','`
  tags=`echo $services | tr ' ' ','`
  command="$command --limit $limit --tags $tags"

fi

if [[ "$@" ]]; then

  # We were passed a list of arguments to the ansible-playbook command, so add
  # these directly to the command that we are building.

  command="$command $@"

fi

if [ -n "$project" ]; then

  # Add the path of the requested, project playbook to the command.

  command="$command /env/$project/$playbook"

else

  # Add the path of the requests, non-project playbook to the command.

  command="$command /env/$playbook"

fi

eval "gosu host_user $command"
