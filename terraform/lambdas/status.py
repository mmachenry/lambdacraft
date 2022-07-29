import os
import json
import boto3

class DatetimeEncoder(json.JSONEncoder):
    def default(self, obj):
        try:
            return super().default(obj)
        except TypeError:
            return str(obj)

def handler (event, callback):
    cluster_arn = os.getenv("CLUSTER_ARN")
    client = boto3.client("ecs")

    list_tasks_response = client.list_tasks(
        cluster = cluster_arn
    )

    tasks_response = {}
    if len(list_tasks_response["taskArns"]) > 0:
        tasks_response = client.describe_tasks(
            cluster = cluster_arn,
            tasks = list_tasks_response["taskArns"]
        )

    list_containers_response = client.list_container_instances(
        cluster = cluster_arn,
    )

    containers_response = {}
    if len(list_containers_response['containerInstanceArns']) > 0:
        containers_response = client.describe_container_instances(
            cluster = cluster_arn,
            containerInstances =
              list_containers_response['containerInstanceArns'],
        )

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps({
            "tasks": tasks_response,
            "containers": containers_response,
        }, cls=DatetimeEncoder)
    }

if __name__ == "__main__":
    print(handler(None,None))
