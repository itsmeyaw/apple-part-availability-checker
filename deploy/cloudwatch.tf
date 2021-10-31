resource "aws_cloudwatch_event_rule" "cron-role" {
  name                = "${var.project_name}-cron-role"
  schedule_expression = "cron(0 0,6,12,18 ? * 1-6 *)"
}

resource "aws_cloudwatch_event_target" "cron-role-target" {
  arn  = aws_lambda_function.apple-notifier.arn
  rule = aws_cloudwatch_event_rule.cron-role.name
}