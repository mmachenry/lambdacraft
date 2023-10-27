import os
import boto3
import json

ecs = boto3.client("ecs")
ec2 = boto3.client("ec2")

def handler (event, callback):
    tasks = ecs.list_tasks(
        cluster = os.getenv("CLUSTER_ARN"),
    )

    if len(tasks['taskArns']) == 0:
        response = ecs.run_task(
            cluster = os.getenv("CLUSTER_ARN"),
            taskDefinition = os.getenv("TASK_ARN"),
            count = 1,
        )
        return {
            'statusCode': 200,
            'body': {
                "message": "Starting the server. Plese wait about 4-6 minutes.",
            }
        }
    else:
        ips = get_ip()
        return {
            'statusCode': 200,
            'body': {
                "message": "There's a task running so not starting.",
                "ips": ips,
            }
        }

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

    instanceIds = list(map(
        lambda d: d['ec2InstanceId'],
        descriptions['containerInstances']))


    ec2_instances = ec2.describe_instances(
        InstanceIds = instanceIds,
    )

    ips = []

    for r in ec2_instances['Reservations']:
        for i in r['Instances']:
            for n in i['NetworkInterfaces']:
                for p in n['PrivateIpAddresses']:
                    ips.append(p['Association']['PublicIp'])

    return ips
