module "api_gateway" {
  source                  = "./modules/api_gateway"
  mv_sqs_uri              = "arn:aws:apigateway:${var.lv_region}:sqs:path/${module.sqs.name}"
  mv_sqs_credentials      = module.iam.api-gateway_role_arn
  mv_dynamodb_table_name  = module.dynamodb.table_name
  mv_dynamodb_uri         = "arn:aws:apigateway:${var.lv_region}:dynamodb:action/Query"
  mv_dynamodb_credentials = module.iam.api-gateway_role_arn
}

module "sqs" {
  source = "./modules/sqs"
}

 module "iam" {
  source      = "./modules/iam"
  mv_sqs_arn  = module.sqs.arn
  mv_dynamodb_arn = module.dynamodb.arn
}

module "lambda" {
  source                = "./modules/lambda"
  mv_sqs_arn            = module.sqs.arn
  mv_lambda_role        = module.iam.lambda_exec_role
  mv_lambda_role_policy = module.iam.lambda_exec_role
}

module "dynamodb" {
  source = "./modules/dynamo_db"
}