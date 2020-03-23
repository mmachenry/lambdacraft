.PHONY: run build deploy

build:
	docker build -t mc .

run:
	docker run -v /home/mmachenry/minecraft/lambdacraft-2020-03-22:/data -p 25565:25565 -p 25575:25575 mc

deploy:
	docker tag lambdacraft2:latest us.gcr.io/minecraft-experimentation/lambdacraft2:latest
	docker push us.gcr.io/minecraft-experimentation/lambdacraft2:latest
