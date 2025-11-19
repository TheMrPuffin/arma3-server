FROM cm2network/steamcmd:root

ENV STEAM_USER anonymous 
ENV STEAM_PASSWORD anonymous
ENV ARMA_CONFIG_FILE /home/steam/arma3/server.cfg

COPY startServer.sh /home/steam/arma3/
COPY server.cfg /home/steam/arma3/

RUN mkdir -p /home/steam/arma3/server/configs/profiles \
    && chown -R steam:steam /home/

USER steam

WORKDIR /home/steam/arma3/server/

VOLUME ["/home/steam/arma3/server"]

EXPOSE 2302/udp 2303/udp 2304/udp 2306/udp 8080/tcp

CMD [ "/home/steam/arma3/startServer.sh" ]