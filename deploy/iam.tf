resource "aws_iam_role" "lambda_function_iam" {
  name               = "${var.project_name}-lambda-role"
  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF
}

resource "aws_iam_policy" "ses_policy" {
  name = "${var.project_name}-ses-policy"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "ses:SendEmail",
            "ses:GetIdentityDkimAttributes",
            "ses:GetIdentityPolicies",
            "ses:PutIdentityPolicy",
            "ses:SendRawEmail",
            "ses:GetIdentityMailFromDomainAttributes",
            "ses:SendBounce",
            "ses:GetIdentityVerificationAttributes",
            "ses:GetIdentityNotificationAttributes",
            "ses:DeleteIdentityPolicy"
          ],
          "Resource" : [
            "arn:aws:ses:*:*:configuration-set/*",
            "arn:aws:ses:*:*:identity/${var.iam_identity}"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ses:ListTemplates",
            "ses:ListCustomVerificationEmailTemplates",
            "ses:GetCustomVerificationEmailTemplate",
            "ses:GetSendStatistics",
            "ses:GetSendQuota",
            "ses:DescribeConfigurationSet",
            "ses:ListReceiptFilters",
            "ses:ListIdentityPolicies",
            "ses:DescribeReceiptRule",
            "ses:DescribeActiveReceiptRuleSet",
            "ses:GetAccountSendingEnabled",
            "ses:ListConfigurationSets",
            "ses:DescribeReceiptRuleSet",
            "ses:ListReceiptRuleSets",
            "ses:ListVerifiedEmailAddresses",
            "ses:GetTemplate",
            "ses:ListIdentities"
          ],
          "Resource" : "*"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "ses_attachment_lambda" {
  policy_arn = aws_iam_policy.ses_policy.arn
  role       = aws_iam_role.lambda_function_iam.name
}