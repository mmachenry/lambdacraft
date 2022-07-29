import os
import json
import boto3

def handler (event, callback):
    cluster_arn = os.getenv("CLUSTER_ARN")
    task_arn = os.getenv("TASK_ARN")

    client = boto3.client("ecs")
    print(task_arn)
    tasks_response = client.describe_tasks(
        cluster = cluster_arn,
        tasks = [task_arn],
    )

    list_containers_response = client.list_container_instances(
        cluster = cluster_arn,
    )

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
        })
    }

if __name__ == "__main__":
    print(handler(None,None))
