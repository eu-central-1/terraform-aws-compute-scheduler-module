locals {
  name_prefix    = "quickscheduler"
  aws_account_id = data.aws_caller_identity.current.account_id
}

module "scheduler" {
  source = "../.."

  name_prefix      = local.name_prefix
}