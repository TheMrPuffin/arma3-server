#!/bin/sh

echo "Starting..."

if [ -z "${STEAM_USER}" ] || [ -z "${STEAM_PASSWORD}" ]; then
    echo "One or both required environment variables (STEAM_USER, STEAM_PASSWORD) are not set."
else

    echo "Starting SteamCMD to download/update server..."

    /home/steam/steamcmd/steamcmd.sh +force_install_dir /home/steam/arma3/server +login $STEAM_USER $STEAM_PASSWORD +app_update 233780 +quit

    echo "Starting SteamCMD..."

    if [ ! -f /mnt/server.cfg ]; then
        echo "Mounted Arma 3 config (/mnt/server.cfg) not detected."
        ARMA_CONFIG_FILE=/home/steam/arma3/server.cfg
    else
        echo "Mounted Arma 3 config (/mnt/server.cfg) detected."
        ARMA_CONFIG_FILE=/mnt/server.cfg
    fi

    echo "Starting Arma 3 server..."

    /home/steam/arma3/server/arma3server_x64 -name="Dockerised Arma 3 Server" -profiles="/home/steam/arma3/server/configs/profiles/" -config="$ARMA_CONFIG_FILE" -port=2302 -world=empty

fi

echo "Stopping..."