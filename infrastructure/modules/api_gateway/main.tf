resource "aws_api_gateway_rest_api" "main" {
  name        = "API_Gateway"
  description = "API Gateway in driver location"
}

resource "aws_api_gateway_resource" "proxy" {
   rest_api_id = aws_api_gateway_rest_api.main.id
   parent_id   = aws_api_gateway_rest_api.main.root_resource_id
   path_part   = "{proxy+}"     # with proxy, this resource will match any request path
}

resource "aws_api_gateway_method" "proxy" {
   rest_api_id   = aws_api_gateway_rest_api.main.id
   resource_id   = aws_api_gateway_resource.proxy.id
   http_method   = "ANY"
   authorization = "NONE"
}