# ingest_lambda.py

import json
import boto3
import uuid
import os

s3 = boto3.client('s3')
BUCKET_NAME = os.environ.get("BUCKET_NAME", "team2-p2-user-activity-events")

def lambda_handler(event, context):
    key = f"user_event_{uuid.uuid4()}.json"
    s3.put_object(Bucket=BUCKET_NAME, Key=key, Body=json.dumps(event))
    return {
        "statusCode": 200,
        "body": json.dumps({"message": "Event stored", "key": key})
    }
