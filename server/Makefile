.PHONY: run build deploy

build:
	docker build -t lambdacraft-server .

run:
	docker run -v  /home/mmachenry/Downloads/lambdacraft-2020-04-29:/data -p 25565:25565 -p 25575:25575 lambdacraft-server

deploy: build
	docker tag lambdacraft-server:latest us.gcr.io/minecraft-experimentation/lambdacraft-server:latest
	docker push us.gcr.io/minecraft-experimentation/lambdacraft-server:latest
