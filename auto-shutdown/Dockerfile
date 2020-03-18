FROM fpco/stack-build:lts-15 as haskell
WORKDIR /opt/build
COPY Main.hs /opt/build
RUN stack ghci --package text --package time --package process --package attoparsec --package attoparsec-iso8601 -- Main.hs

FROM itzg/rcon-cli:latest
COPY --from=haskell /opt/build/Main /Main
ENTRYPOINT /Main
