FROM debian:bullseye

COPY docker-entrypoint.sh /

RUN                                                                            \
  apt-get update                                                            && \
  apt-get --yes --no-install-recommends install                                \
    gosu                                                                       \
    libsasl2-modules                                                           \
    makepasswd                                                                 \
    mutt                                                                       \
    nano

COPY config /config

ENTRYPOINT [ "bash", "/docker-entrypoint.sh" ]
