ARG RELEASE=buster
FROM debian:$RELEASE

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
    openssh-server                                                             \
    psmisc                                                                     \
    python3-apt                                                                \
    python3-minimal                                                            \
    python3-setuptools                                                         \
    rsync                                                                      \
    rsyslog                                                                    \
    sudo                                                                       \
    whois                                                                   && \
  # /run/sshd is not automatically created in container environment
  mkdir /run/sshd                                                           && \
  # Edit to /etc/rsyslog.conf prevents this error message at rsyslog start
  # rsyslogd: imklog: cannot open kernel log (/proc/kmsg): Operation not permitted
  sed -i '/imklog/s/^/#/' /etc/rsyslog.conf                                 && \
  useradd --create-home user1fname                                             \
    --password `mkpasswd --method=md5 user1passwd`                          && \
  usermod --shell /bin/bash user1fname                                      && \
  usermod -a -G sudo user1fname                                             && \
  sed -i                                                                       \
    's/^%sudo\tALL=(ALL:ALL) ALL$/%sudo\tALL=(ALL:ALL) NOPASSWD:ALL/'          \
    /etc/sudoers

# Self-explanatory but put in place the required ENTRYPOINT setup. Have a look
# at the docker-entrypoint.sh script for more insight.
COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT [ "docker-entrypoint.sh" ]
