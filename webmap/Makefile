.PHONY: build run

build:
	docker build -t webmap .

run:
	docker run \
		-e AWS_ACCESS_KEY_ID="$(shell aws configure get aws_access_key_id)" \
		-e AWS_SECRET_ACCESS_KEY="$(shell aws configure get aws_secret_access_key)" \
		-e FTP_HOST="ftp://chi1.mc.cubedhost.com" \
		-e FTP_USER="mike.machenry@gmail.com.10904" \
		-e FTP_PASSWORD="$(FTP_PASSWORD)" \
		-v /home/mmachenry/output:/output \
		-v /home/mmachenry/world:/world \
		webmap
