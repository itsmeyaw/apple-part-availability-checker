data "archive_file" "lambda-function-zip" {
  type        = "zip"
  source_file = "../function"
  output_path = "function.zip"
}

resource "aws_lambda_function" "apple-notifier" {
  function_name    = "${var.project_name}-notifier"
  role             = aws_iam_role.lambda_function_iam.arn
  source_code_hash = filebase64sha256("function.zip")
  filename         = "function.zip"
  timeout          = "1"
  runtime          = "nodejs"
  handler          = "index.handler"
  depends_on       = [data.archive_file.lambda-function-zip]
  environment {
    variables = {
      email_from  = var.notifier_email
      emails_to   = var.receiver_emails
      part_code   = var.part_code
      postal_code = var.postal_code
      city        = var.city
    }
  }
}