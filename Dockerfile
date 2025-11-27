FROM cm2network/steamcmd:steam

ENV A3_HOSTNAME="Containerised Arma 3 Server by TheMrPuffin"

RUN mkdir -p /home/steam/arma3/server/configs/profiles

COPY --chmod=0755 startServer.sh /home/steam/arma3/

WORKDIR /home/steam/arma3/server

VOLUME ["/home/steam/arma3/server"]

EXPOSE 2302/udp 2303/udp 2304/udp 2306/udp

CMD [ "/home/steam/arma3/startServer.sh" ]