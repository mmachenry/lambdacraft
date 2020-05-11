FROM fpco/stack-build:lts-15.4 as haskell
ENV STACK_ROOT /home/stackage/.stack
WORKDIR /opt/build
COPY Main.hs .
RUN stack ghc --package process --package hdaemonize -- -optl-static Main.hs

FROM itzg/minecraft-server:multiarch
COPY --from=haskell /opt/build/Main /Main
COPY start_monitor_and_server /
RUN chmod a+x /start_monitor_and_server
ENV EULA TRUE
ENV VERSION 1.15.2
ENV TYPE PAPER
ENTRYPOINT ["/start_monitor_and_server"]
