build:
	docker build -t lambdacraft .

run:
	docker run -p 25565:25565 lambdacraft

deploy:
	docker build -t lambdacraft .
	docker tag lambdacraft:latest us.gcr.io/minecraft-experimentation/lambdacraft:latest
	docker push us.gcr.io/minecraft-experimentation/lambdacraft:latest
