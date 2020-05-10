FROM ubuntu:latest

ENV TZ America/New_York
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN apt-get install -y git python3 python3-pil python3-dev python3-numpy build-essential wget awscli

RUN git clone https://github.com/overviewer/Minecraft-Overviewer.git
WORKDIR Minecraft-Overviewer
RUN python3 setup.py build

ENV VERSION 1.15
RUN mkdir -p ~/.minecraft/versions/${VERSION}/
RUN wget https://overviewer.org/textures/${VERSION} -O ~/.minecraft/versions/${VERSION}/${VERSION}.jar

COPY renders.cfg .
COPY build_map.sh .
ENTRYPOINT /bin/sh build_map.sh
