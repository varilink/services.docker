# ------------------------------------------------------------------------------
# build/sshd/docker-entrypoint.sh
# ------------------------------------------------------------------------------

# This is launch script for the containers in the repository that simulate hosts
# that are the targets of our Ansible role deployment in our live environment.

# Silently (unless anything it output to STDERR) update the APT cache. This can
# get so out of date that APT tasks start failing and an image rebuild does not
# solve the problem since the Dockerfile RUN is not rerun when the cached layer
# in the initial image build is reused.
apt-get update 1>/dev/null

touch /var/local/services.log
chmod g+w,o+w /var/local/services.log

# Get the IP address via the hostname command.
ipaddr=`hostname -I`

if [[ $ipaddr =~ ^10\.0\.0 ]]; then

  # This host is on our simulation of the office network. Add a route to hosts
  # that are on our simulation of the Internet.

  ip route add 10.0.1.0/24 via 10.0.0.254

elif [[ $ipaddr =~ ^10\.0\.1 ]]; then

  # This host is on our simulation of the Internet. Add a route to hosts that
  # are on our simulation of the office network.

  ip route add 10.0.0.0/24 via 10.0.1.254

fi

# Run the sshd without it detaching or becoming a daemon but run it in the
# background.
/usr/sbin/sshd -D >> /var/local/services.log &

# tail the common log file that sshd and all the services that we will deploy
# using Ansible will append to. That way this tail is what attaches to the
# terminal and we will see messages that all the services write to it.
tail -f /var/local/services.log
