.PHONY build run deploy start

build:
	docker build -t lambdacraft2 .

run:
	docker run -p 25565:25565 lambdacraft2

deploy: build
	docker tag lambdacraft2:latest us.gcr.io/minecraft-experimentation/lambdacraft2:latest
	docker push us.gcr.io/minecraft-experimentation/lambdacraft2:latest

start:
	curl https://us-central1-minecraft-experimentation.cloudfunctions.net/startInstance
