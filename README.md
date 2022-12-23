# lambdacraft
Infrastructure for the Lambdacraft Minecraft server.

# Start the server

    sh scripts/start_server.sh

# Upgrade server

The server needs the VERSION to be changed in the game/Dockerfile and then
you'll need to find and download new versions of all of the mods in the
/mnt/efs/fs1/mods directory that's on the EFS mount. You can access the EFS
from sshing to the EC2 instance that is not usually running. It's an
t3-tiny on Trevor's account that has an efs_volume and
mmachenry-heckbringer.pem as a key. The username is ec2-user

# Logging

    aws logs tail --follow game-task
