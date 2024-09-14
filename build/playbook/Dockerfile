FROM debian:bookworm
ARG UID=1000

RUN                                                                            \
  apt-get update                                                            && \
  apt-get --yes --no-install-recommends install                                \
    ansible                                                                    \
    gosu                                                                       \
    iproute2                                                                   \
    python3-jmespath                                                           \
    sshpass                                                                 && \
    useradd --create-home --uid ${UID} host_user

COPY docker-entrypoint.sh /

ENTRYPOINT ["bash", "/docker-entrypoint.sh"]
