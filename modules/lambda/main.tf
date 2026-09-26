data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "random_pet" "this" {
  length = 2
}

locals {
  aws_account_id = data.aws_caller_identity.current.account_id
  aws_region_id  = data.aws_region.current.region
  python_runtime = "python3.14"

  project_source_path = "${path.module}/code"
  docker_file_path = "Dockerfile"
  docker_source_include  = ["requirements.txt",local.docker_file_path,"src/**"]

  policy_statements = {
    ec2_read = {
      effect    = "Allow",
      actions   = [
                    "ec2:Get*",
                    "ec2:Describe*",
                    "ec2:List*"
                  ],
      resources = ["*"]
    },
    rds_read = {
      effect    = "Allow",
      actions   = [
                    "rds:Get*",
                    "rds:Describe*",
                    "rds:List*"
                  ],
      resources = ["*"]
    },
    ecs_read = {
      effect    = "Allow",
      actions   = [
                    "ecs:Get*",
                    "ecs:Describe*",
                    "ecs:List*"
                  ],
      resources = ["*"]
    }
  }
}

##################################
# Lambda Image Build
##################################

module "image" {
  source              = "../lambda_image"

  create = var.create
  name_prefix = "${var.name_prefix}_al2023"

  project_source_path   = local.project_source_path
  docker_file_path      = local.docker_file_path
  docker_source_include = local.docker_source_include

  platform    = "linux/amd64"

  tags = var.tags
}

##################################
# Lambda Function
##################################

module "function" {
  source              = "terraform-aws-modules/lambda/aws"
  version             = "~>8.1"

  create                   = var.create
  create_package           = false
  recreate_missing_package = false
  image_uri                = module.image.image_uri

  function_name            = var.name_prefix
  handler                  = "handler.scheduler_handler"
  runtime                  = local.python_runtime
  compatible_runtimes      = [local.python_runtime]
  compatible_architectures = ["x86_64"]

  memory_size              = 1024
  ephemeral_storage_size   = 1024
  timeout                  = "600"

  publish                  = true
  package_type             = "Image"

  environment_variables = {
    SCHEDULE_TAG_NAME = "Scheduling"
    POWERTOOLS_SERVICE_NAME = var.name_prefix
    # POWERTOOLS_LOG_LEVEL = "DEBUG"
  }

  create_role = true
  attach_policy_statements = true
  policy_statements = local.policy_statements

  create_current_version_allowed_triggers = false
  allowed_triggers = {
    scheduler = {
      principal  = "events.amazonaws.com"
      source_arn = module.eventbridge.eventbridge_rule_arns["crons"]
    }
  }

  tags = var.tags
}

##################################
# Scheduler Event (EventBridge)
##################################

module "eventbridge" {
  source = "terraform-aws-modules/eventbridge/aws"
  version             = "~>4.3"

  create = var.create
  create_bus = false

  rules = {
    crons = {
      description         = "Trigger for Lambda ${var.name_prefix}"
      schedule_expression = "rate(15 minutes)"
    }
  }

  targets = {
    crons = [
      {
        name  = "${var.name_prefix}_cron"
        arn   = module.function.lambda_function_arn
        input = jsonencode({ "job" : "cron-by-rate" })
      }
    ]
  }

  tags = var.tags
}