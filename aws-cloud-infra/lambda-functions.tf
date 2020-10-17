#######################################################
#              ZIP file for email lambda              #
#######################################################
data "archive_file" "lambda_for_email" {
  type        = "zip"
  source_file = "../challenge-1/email-processor-lambda.py"
  output_path = "../challenge-1/email-processor-lambda.zip"
}

resource "aws_s3_bucket_object" "lambda-package" {
  bucket                 = data.terraform_remote_state.backend.outputs.artifactory_bucket_name
  key                    = var.email-lambda-bucket-key
  source                 = "${path.module}/../challenge-1/email-processor-lambda.zip"
  server_side_encryption = "AES256"
}

#########################################################
#          Lambda function for Email Notification       #
#########################################################
resource "aws_lambda_function" "email_reminder" {
  function_name = var.email-reminder-lambda
  handler       = "email-processor-lambda.lambda_handler"

  filename         = data.archive_file.lambda_for_email.output_path
  source_code_hash = data.archive_file.lambda_for_email.output_base64sha256
  role             = aws_iam_role.lambda_access_role.arn

  memory_size = var.memory-size
  runtime     = "python3.8"
  timeout     = var.time-out

  environment {
    variables = {
      verified_email = var.verified_email
      sns_arn        = aws_cloudformation_stack.sns_reminder_stack.outputs["SNSARN"]
    }
  }
  tags = local.common_tags
}

resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.email_reminder.arn
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.email_processor_api.execution_arn}/*/*/*"
}

