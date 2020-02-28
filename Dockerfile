FROM itzg/minecraft-server
ENV EULA TRUE
ENV VERSION 1.15.2
#ENV VERSION 1.13.2
#ENV TYPE SPIGOT

COPY ./runServerThenKillVM /
RUN chmod 755 /runServerThenKillVM
ENTRYPOINT /runServerThenKillVM
