data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "random_pet" "this" {
  length = 2
}

locals {
  aws_account_id = data.aws_caller_identity.current.account_id
  aws_region_id  = data.aws_region.current.region
  python_runtime = "python3.12"
  name_prefix    = "${var.name_prefix}_scheduler"

  project_source_path = "${path.module}/code"
  docker_file_path = "docker/Dockerfile"
  docker_source_include  = ["requirements.txt",local.docker_file_path,"src/**"]
}

module "image" {
  source              = "../lambda_image"

  create = var.create

  name_prefix = "${local.name_prefix}_al2023"

  project_source_path   = local.project_source_path
  docker_file_path      = local.docker_file_path
  docker_source_include = local.docker_source_include

  platform    = "linux/amd64"

  tags = var.tags
}

module "function" {
  source              = "terraform-aws-modules/lambda/aws"
  version             = "~>8.0.0"

  create                   = var.create
  create_package           = false
  recreate_missing_package = false

  function_name            = local.name_prefix
  handler                  = "handler.create_user_handler"
  runtime                  = local.python_runtime
  compatible_runtimes = [local.python_runtime]
  compatible_architectures = ["x86_64"]

  memory_size              = 1024
  ephemeral_storage_size   = 1024
  timeout                  = "600"

  publish                  = true
  package_type             = "Image"
  image_uri = module.image.image_uri

  replace_security_groups_on_destroy = true
  replacement_security_group_ids     = [data.aws_security_group.default.id]

  attach_network_policy    = true

  environment_variables = {
    POWERTOOLS_SERVICE_NAME = local.name_prefix
    # POWERTOOLS_LOG_LEVEL = "DEBUG"
  }

  attach_policy_statements = true
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
    }
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

  allowed_triggers = {
    Scheduler = {
      principal  = "scheduler.amazonaws.com"
      source_arn = try(aws_scheduler_schedule.this[0].arn, null)
    }
  }

  tags = var.tags
}

##################################
# Scheduler Event (EventBridge)
##################################

resource "aws_iam_role" "scheduler" {
  count = var.create? 1: 0
  name = "${local.name_prefix}_scheduler"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "invoke_function" {
  count = var.create? 1: 0
  name = "${local.name_prefix}_invoke_function"

  role = aws_iam_role.scheduler[0].id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowEventBridgeToInvokeLambda",
        "Action" : [
          "lambda:InvokeFunction"
        ],
        "Effect" : "Allow",
        "Resource" : module.function.lambda_function_arn
      }
    ]
  })

  tags = var.tags
}

resource "aws_scheduler_schedule" "this" {
  count = var.create? 1: 0
  name = "${local.name_prefix}_scheduler"

  flexible_time_window {
    mode = "OFF"
  }
  schedule_expression = "rate(5 minute)"
  target {
    arn = module.function.lambda_function_arn
    role_arn = aws_iam_role.scheduler[0].arn
    input = jsonencode({"input": "rate(5 minute)"})
  }

  tags = var.tags
}