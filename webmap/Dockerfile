FROM ubuntu:latest

RUN apt-get update
RUN apt-get install -y git python3 python3-pil python3-dev python3-numpy build-essential wget
RUN git clone https://github.com/overviewer/Minecraft-Overviewer.git
WORKDIR Minecraft-Overviewer
RUN python3 setup.py build

#RUN apt install -y wget gnupg
#RUN echo "deb https://overviewer.org/debian ./" >> /etc/apt/sources.list
#RUN wget -O - https://overviewer.org/debian/overviewer.gpg.asc | apt-key add -
#RUN apt update
#RUN apt install -y minecraft-overviewer

ENV VERSION 1.15
RUN mkdir -p ~/.minecraft/versions/${VERSION}/
RUN wget https://overviewer.org/textures/${VERSION} -O ~/.minecraft/versions/${VERSION}/${VERSION}.jar

COPY renders.cfg .
ENTRYPOINT /Minecraft-Overviewer/overviewer.py -c renders.cfg
