provider "aws" {
  region = var.region
}

resource "aws_lambda_function" "html_lambda" {
  filename         = "index.zip"
  function_name    = "g35_microservices_lf_successfull"
  role             = aws_iam_role.g35_microservices_lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  source_code_hash = data.archive_file.lambda_package.output_base64sha256
}

resource "aws_iam_role" "g35_microservices_lambda_role" {
  name = "g35_microservices_lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.g35_microservices_lambda_role.name
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.html_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.g35_microservices.execution_arn}/*/*/*"
}

data "archive_file" "lambda_package" {
  type        = "zip"
  source_file = "index.js"
  output_path = "index.zip"
}
