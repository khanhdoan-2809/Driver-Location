module "api_gateway" {
  source = "./modules/api_gateway"
  mv_uri = "arn:aws:apigateway:${var.lv_region}:sqs:path/${module.sqs.name}"
  mv_crendtials = module.iam.sqs_arn
}

module "sqs" {
  source = "./modules/sqs"
}

 module "iam" {
  source = "./modules/iam"
  mv_sqs_arn = module.sqs.arn
}