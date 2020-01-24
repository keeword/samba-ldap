FROM debian:buster
MAINTAINER xieweineng <xieweineng@gmail.com>

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        libpam-ldap \
        libnss-ldap \
        ldap-utils \
        samba && \
    rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /usr/bin/

EXPOSE 137/udp 138/udp 139 445

ENTRYPOINT ["entrypoint.sh"]
