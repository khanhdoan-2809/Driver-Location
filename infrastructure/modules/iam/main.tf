resource "aws_iam_role" "api_sqs" {
    name = "apigateway_sqs"

    assume_role_policy = <<EOF
    {
    "Version": "2012-10-17",
    "Statement": [
        {
        "Action": "sts:AssumeRole",
        "Principal": {
            "Service": "apigateway.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
        }
    ]
    }
    EOF
}

data "template_file" "gateway_policy" {
  template = file("${path.root}/policies/api-gateway-permission.json")

  vars = {
    sqs_arn   = var.mv_sqs_arn
  }
}

resource "aws_iam_policy" "api_policy" {
  name = "api-sqs-cloudwatch-policy"

  policy = data.template_file.gateway_policy.rendered
}

resource "aws_iam_role_policy_attachment" "api_exec_role" {
  role       =  aws_iam_role.api_sqs.name
  policy_arn =  aws_iam_policy.api_policy.arn
}