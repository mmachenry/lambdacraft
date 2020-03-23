FROM fpco/stack-build:lts-15.4 as haskell
ENV STACK_ROOT /home/stackage/.stack
WORKDIR /opt/build
COPY Main.hs .
RUN stack ghc --package process -- -optl-static Main.hs

FROM itzg/rcon-cli:latest
COPY --from=haskell /opt/build/Main /Main
ENV RCON_PORT 25575
ENTRYPOINT ["/Main"]
