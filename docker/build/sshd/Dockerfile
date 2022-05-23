# At the current time, Debian Buster has just transitioned to old stable, i.e.
# an upgrade is needed.
FROM debian:buster

# Create a bare minimum image containing only what is necessary for Ansible to
# start building out containers based on this image.

# Install base required Debian packages, create a user for Ansible connections
# and configure it for seamless privilege escalation. My setup here allows
# privilege escalation to happen without a password check, which I wouldn't
# normally recommend but it's okay here as it's used for containers that I'm
# only ever running on my client machine for testing purposes.
RUN                                                                            \
  apt-get update                                                            && \
  apt-get --yes --no-install-recommends install                                \
    makepasswd                                                                 \
    openssh-server                                                             \
    python-minimal                                                             \
    python-setuptools                                                          \
    rsync                                                                      \
    sudo                                                                    && \
  mkdir /run/sshd                                                           && \
  useradd --create-home user --password `echo -n password                      \
    | makepasswd --crypt --clearfrom - | tr --squeeze-repeats ' '              \
    | cut --delimiter=' ' --fields=2`                                       && \
  usermod --shell /bin/bash user                                            && \
  usermod -a -G sudo user                                                   && \
  sed -i                                                                       \
    's/^%sudo\tALL=(ALL:ALL) ALL$/%sudo\tALL=(ALL:ALL) NOPASSWD:ALL/'          \
    /etc/sudoers

# Self-explanatory but put in place the required ENTRYPOINT setup. Have a look
# at the docker-entrypoint.sh script for more insight.
COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT [ "docker-entrypoint.sh" ]
