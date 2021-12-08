FROM fpco/stack-build:lts-18.8 as haskell
ENV STACK_ROOT /home/stackage/.stack
WORKDIR /opt/build
COPY Main.hs .
RUN stack ghc --package process --package hdaemonize -- -optl-static Main.hs

FROM itzg/minecraft-server:latest
COPY --from=haskell /opt/build/Main /Main
COPY start_monitor_and_server /
RUN chmod a+x /start_monitor_and_server
ENV EULA TRUE
ENV VERSION 1.17
ENTRYPOINT ["/start_monitor_and_server"]
