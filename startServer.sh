#!/usr/bin/env bash

echo "Starting..."

if [ -z "${STEAM_USER}" ] || [ -z "${STEAM_PASSWORD}" ]; then
    echo "One or both required environment variables (STEAM_USER, STEAM_PASSWORD) are not set."
else

    echo "Starting SteamCMD to download/update server..."

    /home/steam/steamcmd/steamcmd.sh \
        +force_install_dir /home/steam/arma3/server \
        +login $STEAM_USER $STEAM_PASSWORD \
        +app_update 233780 \
        +quit

    MODS_DIR="/home/steam/Steam/steamapps/workshop/content/107410"
    MOD_LINK_ROOT="/home/steam/arma3/server"
    MOD_PARAMS=""

    if [ -n "$STEAM_MODS" ]; then
        echo "Mods requested via STEAM_MODS: $STEAM_MODS"

        IFS=', ' read -ra MOD_ARRAY <<< "$STEAM_MODS"

        for mod_id in "${MOD_ARRAY[@]}"; do
            [ -z "$mod_id" ] && continue

            echo "Downloading workshop mod $mod_id..."
            /home/steam/steamcmd/steamcmd.sh \
                +login "$STEAM_USER" "$STEAM_PASSWORD" \
                +workshop_download_item 107410 "$mod_id" validate \
                +quit

            MOD_SOURCE="$MODS_DIR/$mod_id"
            if [ ! -d "$MOD_SOURCE" ]; then
                echo "WARNING: Workshop mod $mod_id not found at $MOD_SOURCE"
                continue
            fi

            MOD_NAME="@mod_${mod_id}"
            MOD_TARGET="$MOD_LINK_ROOT/$MOD_NAME"

            if [ ! -e "$MOD_TARGET" ]; then
                echo "Linking $MOD_TARGET -> $MOD_SOURCE"
                ln -s "$MOD_SOURCE" "$MOD_TARGET"
            fi

            if [ -z "$MOD_PARAMS" ]; then
                MOD_PARAMS="$MOD_NAME"
            else
                MOD_PARAMS="$MOD_PARAMS;$MOD_NAME"
            fi
        done

        echo "Final -mod string: $MOD_PARAMS"
    else
        echo "No mods requested (STEAM_MODS not set)."
    fi

    echo "Checking for mounted server.cfg..."

    if [ ! -f /mnt/server.cfg ]; then
        echo "Mounted Arma 3 config (/mnt/server.cfg) not detected."
        ARMA_CONFIG_FILE=/home/steam/arma3/server.cfg

        # generate config block

        # loop through A3_ environment variables
        env | grep '^A3_' | while IFS='=' read -r key value; do
            # strip prefix
            arma_key="${key#A3_}"

            # if value contains comma OR pipe, treat as array
            if [[ "$value" == *","* || "$value" == *"|"* ]]; then
                # support comma or pipe separated values
                IFS=',|' read -ra items <<< "$value"
                out_items=""
                for item in "${items[@]}"; do
                    # always quote strings
                    out_items+="\"$item\", "
                done
                # trim trailing comma+space
                out_items="${out_items%, }"
                echo "${arma_key}[] = { ${out_items} };" >> "$ARMA_CONFIG_FILE"
            else
                # determine if num or string
                if [[ "$value" =~ ^[0-9.]+$ ]]; then
                    echo "${arma_key} = ${value};" >> "$ARMA_CONFIG_FILE"
                else
                    echo "${arma_key} = \"${value}\";" >> "$ARMA_CONFIG_FILE"
                fi
            fi
        done

        echo "Generated $ARMA_CONFIG_FILE:"

    else
        echo "Mounted Arma 3 config (/mnt/server.cfg) detected."
        ARMA_CONFIG_FILE=/mnt/server.cfg
    fi

    echo "Starting Arma 3 server..."

    CMD=(
        /home/steam/arma3/server/arma3server_x64
        -name="Dockerised Arma 3 Server"
        -profiles="/home/steam/arma3/server/configs/profiles/"
        "-config=$ARMA_CONFIG_FILE"
        -port=2302
        -world=empty
    )

    if [ -n "$MOD_PARAMS" ]; then
        CMD+=("-mod=$MOD_PARAMS")
    fi

    exec "${CMD[@]}"
fi

echo "Stopping..."