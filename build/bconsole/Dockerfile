FROM debian:bullseye

RUN                                                                            \
  apt-get update                                                            && \
  apt-get --yes --no-install-recommends install                                \
    bacula-console

COPY bconsole.conf /etc/bacula/

ENTRYPOINT bconsole
