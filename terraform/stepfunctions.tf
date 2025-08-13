# --- IAM role for Step Functions ---
resource "aws_iam_role" "step_function_role" {
  name = "step-functions-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Action    = "sts:AssumeRole",
      Principal = { Service = "states.amazonaws.com" }
    }]
  })
}

# Policy: allow Step Functions to invoke your Lambda
resource "aws_iam_policy" "sfn_invoke_lambda" {
  name = "sfn-invoke-process-lambda"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["lambda:InvokeFunction"],
      Resource = aws_lambda_function.process_lambda.arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_sfn_invoke_lambda" {
  role       = aws_iam_role.step_function_role.name
  policy_arn = aws_iam_policy.sfn_invoke_lambda.arn
}

# --- State Machine (ProcessEvent only) ---
resource "aws_sfn_state_machine" "user_activity_workflow" {
  name     = "user-activity-pipeline"
  role_arn = aws_iam_role.step_function_role.arn

  definition = jsonencode({
    Comment = "Pipeline to process user activity",
    StartAt = "ProcessEvent",
    States = {
      ProcessEvent = {
        Type     = "Task",
        Resource = aws_lambda_function.process_lambda.arn,
        End      = true
      }
    }
  })
}
