FROM cm2network/steamcmd:steam

ENV STEAM_USER=anonymous \
    STEAM_PASSWORD=anonymous \
    ARMA_CONFIG_FILE=/home/steam/arma3/server.cfg

RUN mkdir -p /home/steam/arma3/server/configs/profiles

COPY --chmod=0755 startServer.sh /home/steam/arma3/
COPY server.cfg /home/steam/arma3/

WORKDIR /home/steam/arma3/server

VOLUME ["/home/steam/arma3/server"]

EXPOSE 2302/udp 2303/udp 2304/udp 2306/udp 8080/tcp

CMD [ "/home/steam/arma3/startServer.sh" ]