# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# IAM Policy Attachment for S3, DynamoDB, CloudWatch access
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_access" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_s3_access" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
resource "aws_iam_role_policy_attachment" "lambda_stepfunctions_access" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSStepFunctionsFullAccess"
}



# Lambda function placeholder - Process Function
resource "aws_lambda_function" "process_lambda" {
  function_name    = "user-activity-processor"
  role             = aws_iam_role.lambda_role.arn
  handler          = "process_lambda.lambda_handler"
  runtime          = "python3.11"
  filename         = "${path.module}/../lambda/process_lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/../lambda/process_lambda.zip")
  timeout          = 10
}

# Lambda function placeholder - sfn_trigger Function
resource "aws_lambda_function" "sfn_trigger" {
  function_name    = "sfn-trigger-lambda"
  role             = aws_iam_role.lambda_role.arn
  handler          = "sfn_trigger.lambda_handler"
  runtime          = "python3.11"
  filename         = "${path.module}/../lambda/sfn_trigger.zip"
  source_code_hash = filebase64sha256("${path.module}/../lambda/sfn_trigger.zip")
  timeout          = 10

  environment {
    variables = {
      STATE_MACHINE_ARN = aws_sfn_state_machine.user_activity_workflow.arn
    }
  }
}
