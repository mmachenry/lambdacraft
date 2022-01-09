import os
import boto3

def handler (event, callback):
    client = boto3.client("ecs")
    response = client.run_task(
        cluster = os.getenv("CLUSTER_ARN"),
        taskDefinition = os.getenv("TASK_ARN"),
        launchType = "FARGATE",
        count = 1,
        networkConfiguration = {
            "awsvpcConfiguration": {
                "subnets": os.getenv("SUBNET_IDS", "").split(","),
                "securityGroups": [os.getenv("SECURITY_GROUP_ID")],
                "assignPublicIp": "ENABLED",
            },
        },
    )
