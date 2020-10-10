############################################
#     onfigure API Gateway Logging         #
############################################
resource "aws_api_gateway_account" "email_processor_config" {
  cloudwatch_role_arn = aws_iam_role.email_processor_role.arn
}

resource "aws_iam_role" "email_processor_role" {
  name = "EmailProcessorAPIGatewayRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "email_processor_policy" {
  name = "EmailProcessorAPIGatewayPolicy"
  role = aws_iam_role.email_processor_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

############################################
#             API Gateway REST API         #
############################################

resource "aws_api_gateway_rest_api" "email_processor_api" {
  # The name of the REST API
  name = "AWSServerlessHackathonAPI"

  description = "A Prototype REST API to execute User request!"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}


#########################################################################
# API Gateway resource, which is a certain path inside the REST API     #
#########################################################################
resource "aws_api_gateway_resource" "email_processor_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.email_processor_api.id
  parent_id   = aws_api_gateway_rest_api.email_processor_api.root_resource_id

  path_part = var.api_gateway_reminder_path
}

#################################################################
# HTTP method to a API Gateway resource (REST endpoint)         #
#################################################################
resource "aws_api_gateway_method" "email_processor_api_method" {
  rest_api_id = aws_api_gateway_rest_api.email_processor_api.id
  resource_id = aws_api_gateway_resource.email_processor_api_resource.id

  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method_settings" "enable_logging" {
  rest_api_id = aws_api_gateway_rest_api.email_processor_api.id
  stage_name  = aws_api_gateway_deployment.email_processor_deployment.stage_name
  method_path = "${aws_api_gateway_resource.email_processor_api_resource.path_part}/${aws_api_gateway_method.email_processor_api_method.http_method}"

  settings {
    metrics_enabled    = true
    data_trace_enabled = true
    logging_level      = "INFO"
  }
}

resource "aws_api_gateway_method_response" "email_processor_method_response_200" {
  depends_on = [aws_api_gateway_method.email_processor_api_method]

  rest_api_id = aws_api_gateway_rest_api.email_processor_api.id
  resource_id = aws_api_gateway_resource.email_processor_api_resource.id
  http_method = aws_api_gateway_method.email_processor_api_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration" "email_processor_api_integration" {
  rest_api_id = aws_api_gateway_rest_api.email_processor_api.id
  resource_id = aws_api_gateway_resource.email_processor_api_resource.id

  http_method             = aws_api_gateway_method.email_processor_api_method.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.email_reminder.invoke_arn
}

####################################
# API Gateway deployment           #
####################################
resource "aws_api_gateway_deployment" "email_processor_deployment" {
  depends_on = [aws_api_gateway_integration.email_processor_api_integration]

  rest_api_id = aws_api_gateway_rest_api.email_processor_api.id
  stage_name  = var.environment
}


