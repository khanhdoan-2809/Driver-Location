output "sqs_arn" {
  value = aws_iam_role.api_sqs.arn
}

output "lambda_exec_role" {
  value = aws_iam_role.lambda_exec_role.arn
}

output "sqs_lambda_role_policy" {
  value = aws_iam_role_policy_attachment.sqs_lambda_role_policy
}