# ------------------------------------------------------------------------------
# build/sshd/Dockerfile
# ------------------------------------------------------------------------------

# This Dockerfile creates a bare minimum image containing only what is necessary
# for Ansible to start building out containers based on this image.

ARG RELEASE=bullseye
FROM debian:$RELEASE

# Install base required Debian packages, create a user for Ansible connections
# and configure it for seamless privilege escalation. My setup here allows
# privilege escalation to happen without a password check, which I wouldn't
# normally recommend but it's okay here as it's used for containers that I'm
# only ever running on my client machine for testing purposes.
RUN                                                                            \
  apt-get update                                                            && \
  apt-get --yes --no-install-recommends install                                \
    iproute2                                                                   \
    lsb-release                                                                \
    openssh-server                                                             \
    procps                                                                     \
    psmisc                                                                     \
    python3-apt                                                                \
    python3-minimal                                                            \
    python3-setuptools                                                         \
    rsync                                                                      \
    sudo                                                                       \
    whois                                                                   && \
  # /run/sshd is not automatically created in container environment
  mkdir /run/sshd                                                           && \
  # create our Ansible user
  useradd --create-home user1fname --shell /bin/bash                           \
    --password `mkpasswd --method=md5 user1passwd`                          && \
  # enable passwordless sudo for our Ansible user
  usermod -a -G sudo user1fname                                             && \
  sed -i                                                                       \
    's/^%sudo\tALL=(ALL:ALL) ALL$/%sudo\tALL=(ALL:ALL) NOPASSWD:ALL/'          \
    /etc/sudoers

# Self-explanatory but put in place the required ENTRYPOINT setup. Have a look
# at the docker-entrypoint.sh script for more insight.
COPY docker-entrypoint.sh /
ENTRYPOINT [ "bash", "/docker-entrypoint.sh" ]
