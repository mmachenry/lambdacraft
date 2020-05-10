#!/bin/sh

WORLD_DIR=/world
mkdir -p $WORLD_DIR
wget --recursive --user=$FTP_USER --password=$FTP_PASSWORD --no-host-directories --directory-prefix $WORLD_DIR $FTP_HOST/Savanah\ Plateau
wget --recursive --user=$FTP_USER --password=$FTP_PASSWORD --no-host-directories --directory-prefix $WORLD_DIR $FTP_HOST/Savanah\ Plateau_nether
wget --recursive --user=$FTP_USER --password=$FTP_PASSWORD --no-host-directories --directory-prefix $WORLD_DIR $FTP_HOST/Savanah\ Plateau_the_end

/Minecraft-Overviewer/overviewer.py -c renders.cfg
aws s3 sync output s3://lambdacraft-overview
