# URL to invoke the API
output "url" {
  value = aws_api_gateway_deployment.email_processor_deployment.invoke_url
}

output "execution_arn" {
  value = aws_api_gateway_deployment.email_processor_deployment.execution_arn
}

output "sns_arn" {
  value       = aws_cloudformation_stack.sns_reminder_stack.outputs["SNSARN"]
  description = "Email SNS topic ARN"
}

output "sns_name" {
  value       = var.display_name
  description = "Email SNS topic name"
}

output "lambda_name" {
  value = aws_lambda_function.email_reminder.id
}