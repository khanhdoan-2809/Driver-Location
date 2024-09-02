resource "aws_api_gateway_rest_api" "main" {
  name        = "API_Gateway"
  description = "API Gateway in driver location"
}

resource "aws_api_gateway_resource" "proxy" {
   rest_api_id = aws_api_gateway_rest_api.main.id
   parent_id   = aws_api_gateway_rest_api.main.root_resource_id
   path_part   = "gateway"
}

resource "aws_api_gateway_resource" "get_id" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "{val}"
}

##################
# Method
##################
resource "aws_api_gateway_method" "any" {
   rest_api_id   = aws_api_gateway_rest_api.main.id
   resource_id   = aws_api_gateway_resource.proxy.id
   http_method   = "ANY"
   authorization = "NONE"
}

resource "aws_api_gateway_method" "get" {
   rest_api_id   = aws_api_gateway_rest_api.main.id
   resource_id   = aws_api_gateway_resource.get_id.id
   http_method   = "GET"
   authorization = "NONE"
}

##################
# Integration
##################
resource "aws_api_gateway_integration" "api-gateway_sqs" {
   rest_api_id             = aws_api_gateway_rest_api.main.id
   resource_id             = aws_api_gateway_method.any.resource_id
   http_method             = aws_api_gateway_method.any.http_method # user invoke api gateway
   type                    = "AWS"
   integration_http_method = "POST" # api gateway invoke sqs
   passthrough_behavior    = "NEVER" # return a 415 Unsupported Media Type  if the incoming request does not match the request template.
   uri                     = var.mv_sqs_uri
   credentials             = var.mv_dynamodb_credentials

  # mapping template
   request_parameters = {
      "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'" # api gateway converts header request for SQS
   }

   request_templates = {
      "application/json" = "Action=SendMessage&MessageBody=$input.body" # api gateway converts the request body into a form suitable for SQS
  }
}

resource "aws_api_gateway_integration" "api-gateway_dynamodb" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_method.get.resource_id
  http_method             = aws_api_gateway_method.get.http_method
  type                    = "AWS"
  integration_http_method = "POST"
  uri                     = var.mv_dynamodb_uri
  credentials             = var.mv_dynamodb_credentials

  request_templates = {
    "application/json" = <<EOF
      {
        "TableName": "${var.mv_dynamodb_table_name}",
        "KeyConditionExpression": "ID = :val",
        "ExpressionAttributeValues": {
          ":val": {
              "S": "$input.params('val')"
          }
        }
      }
    EOF
  }
}

# ##################
# # Response
# ##################

# send a new driver location to sqs to insert
resource "aws_api_gateway_integration_response" "success" {
  rest_api_id       = aws_api_gateway_rest_api.main.id
  resource_id       = aws_api_gateway_resource.proxy.id
  http_method       = aws_api_gateway_method.any.http_method
  status_code       = aws_api_gateway_method_response.response_200.status_code
  response_templates = {
    "application/json" = "{\"message\": \"great success!\"}"
  }

  depends_on = [aws_api_gateway_integration.api-gateway_sqs]
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id       = aws_api_gateway_rest_api.main.id
  resource_id       = aws_api_gateway_resource.proxy.id
  http_method       = aws_api_gateway_method.any.http_method
  status_code       = 200

  response_models = {
    "application/json" = "Empty"
  }
}

# get driver location by id
resource "aws_api_gateway_integration_response" "get_id_response" {
  depends_on  = [aws_api_gateway_integration.api-gateway_dynamodb]
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.get_id.id
  http_method = aws_api_gateway_method.get.http_method
  status_code = aws_api_gateway_method_response.get_id_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  response_templates = {
    "application/json" = <<EOF
      #set($inputRoot = $input.path('$'))
      {
         #foreach($elem in $inputRoot.Items) {
          "ID": "$elem.ID.S",
          "UserID": "$elem.UserID.S",
          "Latitude": "$elem.Latitude.S",
          "Longtitude": "$elem.Longtitude.S", 
          "Date": "$elem.Date.S"
        }#if($foreach.hasNext),#end
        #end
      }
    EOF
  }
}

resource "aws_api_gateway_method_response" "get_id_200" {
  rest_api_id       = aws_api_gateway_rest_api.main.id
  resource_id       = aws_api_gateway_resource.get_id.id
  http_method       = aws_api_gateway_method.get.http_method
  status_code       = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

##################
# Deployment
##################
resource "aws_api_gateway_deployment" "api_gateway" {
  rest_api_id = "${aws_api_gateway_rest_api.main.id}"
  stage_name  = "main"

  depends_on = [aws_api_gateway_integration.api-gateway_sqs, aws_api_gateway_integration.api-gateway_dynamodb]
}