FROM debian:bullseye

RUN                                                                            \
  apt-get update                                                            && \
  apt-get --yes --no-install-recommends install                                \
    iproute2                                                                   \
    traceroute

COPY docker-entrypoint.sh /

ENTRYPOINT [ "bash", "/docker-entrypoint.sh" ]
