resource "aws_dynamodb_table" "user_activity_table" {
  name         = "team2-p2-user-activity"
  billing_mode = "PAY_PER_REQUEST" # No need to manage read/write capacity
  hash_key     = "user_id"
  range_key    = "event_timestamp"

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "event_timestamp"
    type = "S"
  }

  tags = {
    Name        = "user-activity-table"
    Environment = "dev"
  }
}
