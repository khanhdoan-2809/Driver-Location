module "api_gateway" {
  source = "./modules/api_gateway"
}

module "sqs" {
  source = "./modules/sqs"
}