# ------------------------------------------------------------------------------
# build/sshd/docker-entrypoint.sh
# ------------------------------------------------------------------------------

# This is launch script for the containers in the repository that simulate hosts
# that are the targets of our Ansible role deployment in our live environment.

touch /var/local/services.log
chmod g+w,o+w /var/local/services.log

# Run the sshd without it detaching or becoming a daemon but run it in the
# background.
/usr/sbin/sshd -D >> /var/local/services.log &

# tail the common log file that sshd and all the services that we will deploy
# using Ansible will append to. That way this tail is what attaches to the
# terminal and we will see messages that all the services write to it.
tail -f /var/local/services.log
