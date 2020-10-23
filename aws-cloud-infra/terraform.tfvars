profile        = "admin"
default_region = "us-east-1"

log-retention-in-days = 3
email-reminder-lambda = "AWSHackathonEmailReminderLambda"
memory-size           = "128"
time-out              = "60"

email-lambda-bucket-key   = "lambda/email-processor-lambda/email-processor-lambda.zip"
verified_email            = "vivekmishra22117@gmail.com"
api_gateway_reminder_path = "message"
artifactory_bucket_prefix = "aws-serverless-hackathon-artifactory"

sns_stack_name = "sns-reminder-cft-stack"
display_name   = "EmailReminderSNSTopic"