import boto3
import json
import uuid
from datetime import datetime

# Initialize client
s3 = boto3.client('s3')
bucket_name = "team2-p2-user-activity-events"

# Sample event data
event_data = {
    "user_id": "u123",
    "event": "click",
    "timestamp": datetime.utcnow().isoformat() + "Z"
}

# Unique filename
key = f"user_event_{uuid.uuid4()}.json"

# Upload to S3
s3.put_object(Bucket=bucket_name, Key=key, Body=json.dumps(event_data))

print(f"✅ Uploaded file: {key}")
