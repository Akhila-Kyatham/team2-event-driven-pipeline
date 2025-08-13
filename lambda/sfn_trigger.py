import boto3
import json
import os

sfn = boto3.client('stepfunctions')
STATE_MACHINE_ARN = os.environ['STATE_MACHINE_ARN']

def lambda_handler(event, context):
    print("Received event:", json.dumps(event))
    
    response = sfn.start_execution(
        stateMachineArn=STATE_MACHINE_ARN,
        input=json.dumps(event)
    )
    
    print("Started Step Function:", response['executionArn'])
    return {"statusCode": 200}
