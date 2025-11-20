#!/bin/sh
echo "Initialisation script..."

/home/steam/steamcmd/steamcmd.sh +force_install_dir /home/steam/arma3/server +login $STEAM_USER $STEAM_PASSWORD +app_update 233780 +quit

echo "Finished Initialisation..."

echo "Starting Arma 3 server..."

/home/steam/arma3/server/arma3server_x64 -name="Dockerised Arma 3 Server" -profiles="/home/steam/arma3/server/configs/profiles/" -config="$ARMA_CONFIG_FILE" -port=2302 -world=empty

echo "Stopping Arma 3 server..."