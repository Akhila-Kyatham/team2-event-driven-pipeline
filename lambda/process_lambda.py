import json
import boto3
import os
from datetime import datetime

s3 = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')
TABLE_NAME = os.environ.get("TABLE_NAME", "team2-p2-user-activity")

def is_valid_event(data):
    required_fields = ['user_id', 'event', 'timestamp']
    
    # Check for missing fields
    if not all(field in data for field in required_fields):
        return False, "Missing required fields"
    
    # Check for empty/null values
    if not all(data[field] for field in required_fields):
        return False, "Null or empty values found"
    
    # Validate timestamp format (ISO 8601)
    try:
        datetime.fromisoformat(data['timestamp'].replace("Z", "+00:00"))
    except ValueError:
        return False, "Invalid timestamp format"

    # Optional: validate event type
    valid_events = ["login", "logout", "click", "purchase"]
    if data['event'] not in valid_events:
        return False, "Invalid event type"

    return True, "OK"

def lambda_handler(event, context):
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']

    response = s3.get_object(Bucket=bucket, Key=key)
    data = json.loads(response['Body'].read())

    # Validate data
    is_valid, reason = is_valid_event(data)
    if not is_valid:
        print(f"Invalid data skipped: {reason}")
        return {
            "statusCode": 400,
            "body": json.dumps({"error": reason})
        }
    data["event_timestamp"] = data.pop("timestamp")
    # Store in DynamoDB
    table = dynamodb.Table(TABLE_NAME)
    table.put_item(Item=data)

    return {
        "statusCode": 200,
        "body": json.dumps("Validated and stored in DynamoDB")
    }
