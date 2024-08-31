resource "aws_api_gateway_rest_api" "main" {
  name        = "API_Gateway"
  description = "API Gateway in driver location"
}

resource "aws_api_gateway_resource" "proxy" {
   rest_api_id = aws_api_gateway_rest_api.main.id
   parent_id   = aws_api_gateway_rest_api.main.root_resource_id
   path_part   = "gateway"     # with proxy, this resource will match any request path
}

resource "aws_api_gateway_method" "proxy" {
   rest_api_id   = aws_api_gateway_rest_api.main.id
   resource_id   = aws_api_gateway_resource.proxy.id
   http_method   = "ANY"
   authorization = "NONE"
}

##################
# Integration
##################
resource "aws_api_gateway_integration" "api" {
   rest_api_id             = aws_api_gateway_rest_api.main.id
   resource_id             = aws_api_gateway_method.proxy.resource_id
   http_method             = aws_api_gateway_method.proxy.http_method # user invoke api gateway
   type                    = "AWS"
   integration_http_method = "POST" # api gateway invoke sqs
   passthrough_behavior    = "NEVER" # return a 415 Unsupported Media Type  if the incoming request does not match the request template.
   uri                     = var.mv_uri
   credentials             = var.mv_crendtials

   request_parameters = {
      "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'" # api gateway converts header request for SQS
   }

   request_templates = {
      "application/json" = "Action=SendMessage&MessageBody=$input.body" # api gateway converts the request body into a form suitable for SQS
  }
}

# ##################
# # Response
# ##################
resource "aws_api_gateway_integration_response" "success" {
  rest_api_id       = aws_api_gateway_rest_api.main.id
  resource_id       = aws_api_gateway_resource.proxy.id
  http_method       = aws_api_gateway_method.proxy.http_method
  status_code       = aws_api_gateway_method_response.response_200.status_code
  response_templates = {
    "application/json" = "{\"message\": \"great success!\"}"
  }

  depends_on = [aws_api_gateway_integration.api]
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id       = aws_api_gateway_rest_api.main.id
  resource_id       = aws_api_gateway_resource.proxy.id
  http_method       = aws_api_gateway_method.proxy.http_method
  status_code       = 200

  response_models = {
    "application/json" = "Empty"
  }
}

##################
# Deployment
##################
resource "aws_api_gateway_deployment" "api_gateway" {
  rest_api_id = "${aws_api_gateway_rest_api.main.id}"
  stage_name  = "main"

  depends_on = [aws_api_gateway_integration.api]
}