FROM cm2network/steamcmd:steam

LABEL org.opencontainers.image.title="Arma 3 Dedicated Server"
LABEL org.opencontainers.image.description="A fully containerised Arma 3 dedicated server using SteamCMD."
LABEL org.opencontainers.image.source="https://github.com/TheMrPuffin/arma3-server"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.authors="Alexander Garner <github.com/TheMrPuffin>"
LABEL org.opencontainers.image.version="${IMAGE_VERSION}"

ENV A3_HOSTNAME="Containerised Arma 3 Server by TheMrPuffin"

RUN mkdir -p /home/steam/arma3/server/configs/profiles

COPY --chmod=0755 startServer.sh /home/steam/arma3/

WORKDIR /home/steam/arma3/server

VOLUME ["/home/steam/arma3/server"]

EXPOSE 2302/udp 2303/udp 2304/udp 2306/udp

CMD [ "/home/steam/arma3/startServer.sh" ]