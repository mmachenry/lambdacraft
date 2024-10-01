repository := "703606424838.dkr.ecr.us-east-1.amazonaws.com/game-repository"

build:
  docker build -t lambdacraft-server .

run: build
  #docker run -v  /home/mmachenry/Downloads/archive-1638830958891:/data -p 25565:25565 -p 25575:25575 lambdacraft-server
  docker run -p 25565:25565 -p 25575:25575 lambdacraft-server

deploy: build login
  docker tag lambdacraft-server:latest {{repository}}:latest
  docker push {{repository}}:latest

login:
  aws --region us-east-1 ecr get-login-password | docker login --username AWS --password-stdin {{repository}}
