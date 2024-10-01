FROM fpco/stack-build:lts-18.8 as haskell
ENV STACK_ROOT /home/stackage/.stack
WORKDIR /opt/build
COPY stack.yaml package.yaml ./
COPY Main.hs .
RUN stack ghc --system-ghc --package hdaemonize -- -optl-static Main.hs

FROM itzg/minecraft-server:java21
COPY --from=haskell /opt/build/Main /Main
COPY start_monitor_and_server /
RUN chmod a+x /start_monitor_and_server
ENV EULA TRUE
#ENV TYPE FABRIC
ENV MEMORY 6G
ENV VERSION 1.21.1
ENV USE_AIKAR_FLAGS true
ENTRYPOINT ["/start_monitor_and_server"]
