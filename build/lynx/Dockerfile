FROM debian:bullseye

COPY addn-hosts /
COPY docker-entrypoint.sh /

RUN                                                                            \
  chmod u=rwx,go=rx /docker-entrypoint.sh                                   && \
  apt-get update                                                            && \
  apt-get --yes --no-install-recommends install                                \
    lynx

ENTRYPOINT ["/docker-entrypoint.sh"]
