import os
import boto3
import json
import datetime

ecs = boto3.client("ecs")
ec2 = boto3.client("ec2")

def JsonDatetime(o):
  if isinstance(o, datetime.datetime):
    return o.isoformat()

def handler (event, context):
    list_tasks_resp = ecs.list_tasks(
        cluster = os.getenv("CLUSTER_ARN"),
    )
    task_arns = list_tasks_resp['taskArns']

    if len(task_arns) == 0:
        method = event['requestContext']['http']['method']
        if method == 'GET':
            body = {
                "message": "No server is running."
            }
        elif method == 'POST':
            response = ecs.run_task(
                cluster = os.getenv("CLUSTER_ARN"),
                taskDefinition = os.getenv("TASK_ARN"),
                count = 1,
            )
            body = {
                "message": "Starting the server. Plese wait about 4-6 minutes.",
            }
    else:
        info = get_info(task_arns)
        body = {
            "message": "There's a task running so not starting.",
            "info": info,
        }

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps(body, default = JsonDatetime),
    }


def get_info (task_arns):
    describe_tasks_resp = ecs.describe_tasks(
        cluster = os.getenv("CLUSTER_ARN"),
        tasks = task_arns,
    )

    task_info = map(
        lambda t: {
            key: t[key]
            for key in ['createdAt', 'desiredStatus', 'executionStoppedAt','lastStatus','startedAt','stopCode','stoppedAt','stoppedReason']
            if key in t
        },
        describe_tasks_resp['tasks'],
    )

    container_instance_arns = [
        t['containerInstanceArn']
        for t in describe_tasks_resp['tasks']
        if 'containerInstanceArn' in t
    ]

    ips = []

    if len(list(container_instance_arns)) > 0:
        describe_container_instances_resp = ecs.describe_container_instances(
            cluster = os.getenv("CLUSTER_ARN"),
            containerInstances = list(container_instance_arns),
        )

        ec2_instance_ids = [
            d['ec2InstanceId']
            for d in describe_container_instances_resp['containerInstances']
            if 'ec2InstanceId' in d
        ]

        describe_instances_resp = ec2.describe_instances(
            InstanceIds = list(ec2_instance_ids),
        )

        for r in describe_instances_resp['Reservations']:
            for i in r['Instances']:
                for n in i['NetworkInterfaces']:
                    for p in n['PrivateIpAddresses']:
                        ips.append(p['Association']['PublicIp'])

    return {
        "tasks": list(task_info),
        "ips": ips,
    }

if __name__ == '__main__':
    print(handler(None, None))
