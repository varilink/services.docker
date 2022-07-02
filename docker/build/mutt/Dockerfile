FROM debian:bullseye

COPY docker-entrypoint.sh /usr/local/sbin/

RUN                                                                            \
  chmod +x /usr/local/sbin/docker-entrypoint.sh                             && \
  apt-get update                                                            && \
  apt-get --yes --no-install-recommends install                                \
    gosu                                                                       \
    makepasswd                                                                 \
    mutt                                                                       \
    nano                                                                    && \
  useradd --create-home username1 --password `echo -n userpass1                \
    | makepasswd --crypt --clearfrom - | tr --squeeze-repeats ' '              \
    | cut --delimiter=' ' --fields=2`                                       && \
  useradd --create-home username2 --password `echo -n userpass2                \
    | makepasswd --crypt --clearfrom - | tr --squeeze-repeats ' '              \
    | cut --delimiter=' ' --fields=2`

COPY config /config

ENTRYPOINT ["docker-entrypoint.sh"]
