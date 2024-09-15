FROM debian:bookworm

RUN                                                                            \
  apt-get update                                                            && \
  apt-get install --yes --no-install-recommends                                \
    iproute2                                                                   \
    squid

COPY docker-entrypoint.sh /

ENTRYPOINT ["bash", "/docker-entrypoint.sh"]
