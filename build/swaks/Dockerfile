FROM debian:bookworm

RUN                                                                            \
  apt-get update                                                            && \
  apt-get --yes --no-install-recommends install                                \
    swaks

ADD https://www.eicar.org/download/eicar-com/\
?wpdmdl=8840&refresh=65fe8dcfd5ffd1711181263 /eicar.com

COPY docker-entrypoint.sh /

ENTRYPOINT [ "bash", "/docker-entrypoint.sh" ]
