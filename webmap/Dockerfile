FROM ubuntu:latest

RUN apt update
RUN apt install -y wget gnupg

RUN echo "deb https://overviewer.org/debian ./" >> /etc/apt/sources.list
RUN wget -O - https://overviewer.org/debian/overviewer.gpg.asc | apt-key add -
RUN apt update
RUN apt install -y minecraft-overviewer

COPY renders.cfg .
ENTRYPOINT overviewer.py -c renders.cfg
