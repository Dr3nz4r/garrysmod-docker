#!/bin/bash
if [ -n "${NAME}" ];
then
    ARGS="+hostname \"${NAME}\" ${ARGS}"
fi

if [ -n "${GSLT}" ];
then
    ARGS="+sv_setsteamaccount \"${GSLT}\" ${ARGS}"
fi

if [ -n "${AUTHKEY}" ];
then
    ARGS="-authkey \"${AUTHKEY}\" ${ARGS}"
fi

if [ -n "${PRODUCTION}" ] && [ "${PRODUCTION}" -ne 0 ];
then
    MODE="production"
    ARGS="-disableluarefresh ${ARGS}"
else
    MODE="development"
    ARGS="-gdb gdb -debug ${ARGS}"
fi

# START THE SERVER
echo "Starting server on ${MODE} mode..."

echo ":/home/container$ /home/container/server/srcds_run -game garrysmod -norestart -strictportbind -autoupdate -steam_dir /home/container/steamcmd -steamcmd_script /home/container/update.txt -port ${PORT} -maxplayers ${MAXPLAYERS}"

/home/container/server/srcds_run \
    -game garrysmod \
    -norestart \
    -strictportbind \
    -autoupdate \
    -steam_dir "/home/container/steamcmd" \
    -steamcmd_script "/home/container/update.txt" \
    -port "${PORT}" \
    -maxplayers "${MAXPLAYERS}" \
    +gamemode "${GAMEMODE}" \
    +map "${MAP}" "${ARGS}"
