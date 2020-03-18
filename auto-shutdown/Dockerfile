FROM fpco/stack-build:lts-15.4 as haskell
WORKDIR /opt/build
COPY Main.hs /opt/build
RUN stack ghc --package process -- Main.hs

FROM itzg/rcon-cli:latest as rcon

FROM ubuntu:latest
COPY --from=rcon /rcon-cli /rcon-cli
COPY --from=haskell /opt/build/Main /Main
ENV RCON_PORT 25575
ENTRYPOINT ["/Main"]
#ENTRYPOINT ["/rcon-cli", "list"]
