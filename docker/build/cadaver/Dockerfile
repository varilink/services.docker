FROM debian:bullseye

RUN                                                                            \
  apt-get update                                                            && \
  apt-get --yes --no-install-recommends install                                \
    cadaver

ENTRYPOINT [ "cadaver", "http://caldav:5232" ]
