FROM debian:bullseye

RUN                                                                            \
  apt-get update                                                            && \
  apt-get --yes --no-install-recommends install                                \
    lynx

COPY docker-entrypoint.sh /

ENTRYPOINT ["dash", "/docker-entrypoint.sh"]
