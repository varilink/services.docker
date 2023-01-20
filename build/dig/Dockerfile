FROM debian:bullseye

COPY docker-entrypoint.sh /

RUN                                                                            \
  chmod u=rwx,go=rx /docker-entrypoint.sh                                   && \
  apt-get update                                                            && \
  apt-get --yes --no-install-recommends install                                \
    bind9-dnsutils

ENTRYPOINT ["/docker-entrypoint.sh"]
