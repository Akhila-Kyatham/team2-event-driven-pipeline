# S3 Bucket to store raw user activity data
resource "aws_s3_bucket" "user_activity_bucket" {
  bucket        = "team2-p2-user-activity-events"
  force_destroy = true

  tags = {
    Name        = "user-activity-events"
    Environment = "dev"
  }
}

# Block all public access to the bucket
resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket = aws_s3_bucket.user_activity_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning on the bucket
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.user_activity_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Give S3 permission to invoke the sfn_trigger Lambda
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sfn_trigger.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.user_activity_bucket.arn
}

# Configure S3 event to trigger sfn_trigger Lambda on .json upload
resource "aws_s3_bucket_notification" "trigger_step_function" {
  bucket = aws_s3_bucket.user_activity_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.sfn_trigger.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".json"
  }

  depends_on = [aws_lambda_permission.allow_s3]
}
