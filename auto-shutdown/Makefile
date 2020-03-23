.PHONY: run build deploy

build:
	docker build -t auto-shutdown .

run:
	docker run -e LAMBDACRAFT_HOST=192.168.0.104 auto-shutdown

deploy:
	docker tag auto-shutdown:latest us.gcr.io/minecraft-experimentation/auto-shutdown:latest
	docker push us.gcr.io/minecraft-experimentation/auto-shutdown:latest
