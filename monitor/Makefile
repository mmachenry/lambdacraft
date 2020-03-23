.PHONY: run build deploy

build:
	docker build -t lambdacraft-monitor .

run:
	docker run -e LAMBDACRAFT_HOST=192.168.0.104 lambdacraft-monitor

deploy: build
	docker tag lambdacraft-monitor:latest us.gcr.io/minecraft-experimentation/lambdacraft-monitor:latest
	docker push us.gcr.io/minecraft-experimentation/lambdacraft-monitor:latest
