server
---

This module of the project is the main Minecraft server in a container, based
on [itzg's minecraft-server](https://hub.docker.com/r/itzg/minecraft-server/)
Dockerfile. The updates we've made to it run a tiny daemon alongside it that
will continually check for the number of users on the server using the rcon
service. If it notices 10 minutes of continuous inactivity, that daemon issues
a stop command through rcon, the Minecraft server gracefully shuts itself down
and the container will complete running.
