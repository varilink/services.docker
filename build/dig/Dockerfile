FROM debian:bullseye

COPY docker-entrypoint.sh /

RUN                                                                            \
  apt-get update                                                            && \
  apt-get --yes --no-install-recommends install                                \
    bind9-dnsutils                                                             \
    iproute2

ENTRYPOINT ["bash", "/docker-entrypoint.sh"]
