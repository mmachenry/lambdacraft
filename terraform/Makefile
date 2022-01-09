.PHONY: format apply run_server

apply:
	terraform apply

format:
	ls *.tf | xargs -I _ terraform fmt _

run_server:
	aws ecs run-task --cluster=game-cluster --task-definition=game --launch-type="FARGATE" --network-configuration="awsvpcConfiguration={subnets=[subnet-005e0087538fc193c],securityGroups=[sg-0658e32cf55facacf],assignPublicIp=ENABLED}"
