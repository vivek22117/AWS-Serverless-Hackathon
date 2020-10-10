#Define policy and role for AWS Lambda
resource "aws_iam_role" "lambda_access_role" {
  name = "EmailProcessorLambdaAccessRole"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "lambda.amazonaws.com"
            },
            "Effect": "Allow"
        }
    ]
}
EOF

}

resource "aws_iam_policy" "lambda_access_policy" {
  name        = "EmailProcessorLambdaAccessPolicy"
  description = "Policy attached for lambda access"
  path        = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
          "s3:Get*",
          "s3:Put*",
          "s3:List*"
      ],
      "Resource": [
          "${aws_s3_bucket.s3_artifactory_bucket.arn}",
          "${aws_s3_bucket.s3_artifactory_bucket.arn}/*"
        ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Action": [
        "sns:*"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "lambda_role_attach" {
  policy_arn = aws_iam_policy.lambda_access_policy.arn
  role       = aws_iam_role.lambda_access_role.name
}

