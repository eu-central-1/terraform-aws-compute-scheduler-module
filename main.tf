module "lambda" {
  source = "./modules/lambda"
  create = var.create

  name_prefix      = "${var.name_prefix}_lambda"
  tags = var.tags
}