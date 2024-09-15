FROM debian:bookworm

RUN                                                                            \
  apt-get update                                                            && \
  apt-get --yes --no-install-recommends install                                \
    cadaver

COPY docker-entrypoint.sh /

ENTRYPOINT [ "bash", "/docker-entrypoint.sh" ]
