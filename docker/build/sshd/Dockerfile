FROM debian:buster

# Create a bare minimum image containing only what is necessary for Ansible to
# start building out containers based on this image.

RUN                                                                            \
  apt-get update                                                            && \
  apt-get --yes --no-install-recommends install                                \
    openssh-server                                                             \
    python-minimal                                                             \
    python-setuptools                                                          \
    rsync                                                                      \
    sudo                                                                    && \
  mkdir /run/sshd                                                           && \
  useradd --create-home user                                                && \
  usermod --shell /bin/bash user                                            && \
  usermod -a -G sudo user                                                   && \
  sed -i                                                                       \
    's/^%sudo\tALL=(ALL:ALL) ALL$/%sudo\tALL=(ALL:ALL) NOPASSWD:ALL/'          \
    /etc/sudoers                                                            && \
  mkdir --mode=700 ~user/.ssh

# Copy client public key to authorized_keys keys for convenient Ansible
# connections. You will need to provide your own.
COPY authorized_keys /home/user/.ssh/

# Set permissions properly for .ssh and its content. This is kind of academic
# since I'm only ever using these containers on my client machine.
RUN                                                                            \
  chmod 600 ~user/.ssh/authorized_keys                                      && \
  chown -R user:user ~user/.ssh

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT [ "docker-entrypoint.sh" ]
