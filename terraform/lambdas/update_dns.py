import boto3

def handler(event, context):
    print(event)
    print(context)

    ec2 = boto3.resource('ec2')
    instance = ec2.Instance(event['detail']['instance-id'])
    new_ip = instance.public_ip_address

    print(new_ip)

    client = boto3.client("route53")
    # TODO: Pull these from env variables.
    hosted_zone_id = "ZOQDXS6QXD97N" # os.genenv("hosted_zone_id")
    hostname = "heckbringer.com" # os.getenv("HOSTNAME")

    response = client.change_resource_record_sets(
        HostedZoneId=hosted_zone_id,
        ChangeBatch={
            "Comment": "Automatic DNS update",
            "Changes": [
                {
                    "Action": "UPSERT",
                    "ResourceRecordSet": {
                        "Name": hostname,
                        "Type": "A",
                        "TTL": 60,
                        "ResourceRecords": [
                            {
                                "Value": new_ip
                            },
                        ],
                    }
                },
            ]
        }
    )

    return {
        'statusCode': 200,
    }
