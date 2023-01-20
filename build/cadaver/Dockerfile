FROM debian:bullseye

RUN                                                                            \
  apt-get update                                                            && \
  apt-get --yes --no-install-recommends install                                \
    cadaver

COPY docker-entrypoint.sh /

RUN chmod u=rwx,go=rx /docker-entrypoint.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]
