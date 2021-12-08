.PHONY: run build deploy

build:
	docker build -t lambdacraft-server .

run:
	docker run -v  /home/mmachenry/Downloads/archive-1638830958891:/data -p 25565:25565 -p 25575:25575 lambdacraft-server

deploy: build
	docker tag lambdacraft-server:latest us.gcr.io/minecraft-experimentation/lambdacraft-server:latest
	docker push us.gcr.io/minecraft-experimentation/lambdacraft-server:latest
