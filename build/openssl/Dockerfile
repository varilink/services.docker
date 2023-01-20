FROM debian:bullseye

COPY docker-entrypoint.sh /

RUN                                                                            \
  chmod +x /docker-entrypoint.sh                                            && \
  apt-get update                                                            && \
  apt-get --yes --no-install-recommends install                                \
    ca-certificates                                                             \
    openssl

ENTRYPOINT ["/docker-entrypoint.sh"]
