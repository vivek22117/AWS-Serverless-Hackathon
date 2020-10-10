#####################################################
# Adding the lambda archive to the defined bucket   #
#####################################################
resource "aws_s3_bucket" "s3_artifactory_bucket" {
  bucket = "${var.artifactory_bucket_prefix}-${var.environment}-${var.default_region}"
  acl    = "private"

  force_destroy = false

  lifecycle {
    prevent_destroy = "true"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true
    id      = "deploy"
    prefix  = "deploy/"

    noncurrent_version_expiration {
      days = 1
    }
  }

  tags = merge(local.common_tags, map("name", "aritifactory-bucket-${var.environment}"))
}

#######################################################
#              ZIP file for email lambda              #
#######################################################
data "archive_file" "lambda_for_email" {
  type        = "zip"
  source_file = "../challenge-1/email-processor-lambda.py"
  output_path = "../challenge-1/email-processor-lambda.zip"
}

resource "aws_s3_bucket_object" "lambda-package" {
  bucket                 = aws_s3_bucket.s3_artifactory_bucket.id
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

