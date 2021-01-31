# BASE IMAGE
FROM debian:buster-slim

LABEL maintainer="ceifa"
LABEL description="A structured Garry's Mod dedicated server under a debian linux image"

ENV DEBIAN_FRONTEND noninteractive
# INSTALL NECESSARY PACKAGES
RUN dpkg --add-architecture i386 && apt-get update && apt-get -y --no-install-recommends --no-install-suggests install \
    wget ca-certificates tar gcc g++ lib32gcc1 libgcc1 libcurl4-gnutls-dev:i386 libssl1.1 libcurl4:i386 libtinfo5 lib32z1 lib32stdc++6 libncurses5:i386 libcurl3-gnutls:i386 gdb libsdl1.2debian libfontconfig net-tools

# CLEAN UP
RUN apt-get clean
RUN rm -rf /tmp/* /var/lib/apt/lists/*

# SET STEAM USER
RUN useradd -m -d /home/container container
USER container

ENV  USER=container HOME=/home/container

WORKDIR /home/container

COPY ./entrypoint.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]

