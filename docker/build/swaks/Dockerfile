FROM debian:bullseye

COPY docker-entrypoint.sh /

RUN                                                                            \
  apt-get update                                                            && \
  apt-get --yes --no-install-recommends install                                \
    swaks

ENTRYPOINT [ "bash", "/docker-entrypoint.sh" ]
