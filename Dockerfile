FROM itzg/minecraft-server
ENV EULA TRUE
ENV VERSION 1.15.2
#ENV VERSION 1.13.2
#ENV TYPE SPIGOT
ENTRYPOINT /start && curl https://us-central1-minecraft-experimentation.cloudfunctions.net/stopInstance
