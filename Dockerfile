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

#COPY ./entrypoint.sh /entrypoint.sh

#CMD ["/bin/bash", "/entrypoint.sh"]

RUN mkdir /home/container/server && mkdir /home/container/steamcmd

# INSTALL STEAMCMD
RUN wget -P /home/container/steamcmd/ https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
    && tar -xvzf /home/container/steamcmd/steamcmd_linux.tar.gz -C /home/container/steamcmd \
    && rm -rf /home/container/steamcmd/steamcmd_linux.tar.gz

# SETUP STEAMCMD TO DOWNLOAD GMOD SERVER
COPY assets/update.txt /home/container/update.txt
RUN /home/container/steamcmd/steamcmd.sh +runscript /home/container/update.txt +quit

# SETUP CSS CONTENT
RUN /home/container/steamcmd/steamcmd.sh +login anonymous \
    +force_install_dir /home/container/temp \
    +app_update 232330 validate \
    +quit
RUN mkdir /home/container/mounts && mv /home/container/temp/cstrike /home/container/mounts/cstrike
RUN rm -rf /home/container/temp

# SETUP BINARIES FOR x32 and x64 bits
RUN mkdir -p /home/container/.steam/sdk32 \
    && cp -v /home/container/steamcmd/linux32/steamclient.so /home/container/.steam/sdk32/steamclient.so \
    && mkdir -p /home/container/.steam/sdk64 \
    && cp -v /home/container/steamcmd/linux64/steamclient.so /home/container/.steam/sdk64/steamclient.so

# SET GMOD MOUNT CONTENT
RUN echo '"mountcfg" {"cstrike" "/home/container/mounts/cstrike"}' > /home/container/server/garrysmod/cfg/mount.cfg

# CREATE DATABASE FILE
RUN touch /home/container/server/garrysmod/sv.db

# CREATE CACHE FOLDERS
RUN mkdir -p /home/container/server/steam_cache/content && mkdir -p /home/container/server/garrysmod/cache/srcds

# PORT FORWARDING
# https://developer.valvesoftware.com/wiki/Source_Dedicated_Server#Connectivity
EXPOSE 27015
EXPOSE 27015/udp
EXPOSE 27005/udp

# SET ENVIRONMENT VARIABLES
ENV MAXPLAYERS="16"
ENV GAMEMODE="sandbox"
ENV MAP="gm_construct"
ENV PORT="27015"

# ADD START SCRIPT
COPY --chown=steam:steam assets/start.sh /home/container/start.sh
RUN chmod +x /home/container/start.sh

# CREATE HEALTH CHECK
COPY --chown=steam:steam assets/health.sh /home/container/health.sh
RUN chmod +x /home/container/health.sh
HEALTHCHECK --start-period=10s \
    CMD /home/container/health.sh

# START THE SERVER
CMD ["/home/container/start.sh"]
