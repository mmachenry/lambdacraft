import os
import boto3

ecs = boto3.client("ecs")
ec2 = boto3.client("ec2")

def handler (event, callback):
    print("startup lambda invoked")
    tasks = ecs.list_tasks(
        cluster = os.getenv("CLUSTER_ARN"),
    )

    if len(tasks['taskArns']) == 0:
        response = ecs.run_task(
            cluster = os.getenv("CLUSTER_ARN"),
            taskDefinition = os.getenv("TASK_ARN"),
            count = 1,
        )
        print("No tasks running. Starting server")
    else:
        print("Tasks running. ", tasks)
        ip = get_ip()
        print("IP info", ip)

def get_ip():
    container_instances = ecs.list_container_instances(
        cluster = os.getenv("CLUSTER_ARN"),
    )

    if len(container_instances['containerInstanceArns']) == 0:
        return None

    descriptions = ecs.describe_container_instances(
        cluster = os.getenv("CLUSTER_ARN"),
        containerInstances = container_instances['containerInstanceArns'],
    )

    print(descriptions)
    instanceIds = list(map(
        lambda d: d['ec2InstanceId'],
        descriptions['containerInstances']))

    print(instanceIds)
    ec2_instances = ec2.describe_instances(
        InstanceIds = instanceIds,
    )

if __name__ == '__main__':
    handler(None, None)
