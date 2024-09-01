# module "api_gateway" {
#   source        = "./modules/api_gateway"
#   mv_uri        = "arn:aws:apigateway:${var.lv_region}:sqs:path/${module.sqs.name}"
#   mv_crendtials = module.iam.sqs_arn
# }

# module "sqs" {
#   source = "./modules/sqs"
# }

#  module "iam" {
#   source      = "./modules/iam"
#   mv_sqs_arn  = module.sqs.arn
# }

# module "lambda" {
#   source                = "./modules/lambda"
#   mv_sqs_arn            = module.sqs.arn
#   mv_lambda_role        = module.iam.lambda_exec_role
#   mv_lambda_role_policy = module.iam.lambda_exec_role
# }

module "dynamodb" {
  source = "./modules/dynamo_db"
}