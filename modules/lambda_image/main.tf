data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "random_pet" "this" {
  length = 2
}

locals {
  docker_image_name = "${var.name_prefix}_${random_pet.this.id}"
  docker_source_include  = contains(var.docker_source_include, var.docker_file_path) ? var.docker_source_include: concat(var.docker_source_include, var.docker_file_path)
  docker_context_include = setunion([for f in local.docker_source_include : fileset(var.project_source_path, f)]...)
  docker_source_sha = sha1(join("", [for f in sort(local.docker_context_include) : filesha1("${var.project_source_path}/${f}")]))

  ecr_address    = format("%v.dkr.ecr.%v.amazonaws.com", data.aws_caller_identity.current.account_id, data.aws_region.current.region)
  ecr_repo       = var.create? local.docker_image_name: "null"
  image_tag      = "latest"
  ecr_image_name = format("%v/%v", local.ecr_address, local.ecr_repo)

  docker_registry_image_name = var.create? docker_registry_image.this[0].name: "null"
  docker_registry_image_id   = var.create? docker_registry_image.this[0].id: "null"
}

resource "docker_image" "this" {
  count = var.create ? 1 : 0

  name = "${local.ecr_image_name}:${local.image_tag}"

  build {
    context    = var.project_source_path
    dockerfile = var.docker_file_path
    platform   = var.platform
  }

  force_remove = true
  keep_locally = false
  triggers     = {
    dir_sha = local.docker_source_sha
  }
}

resource "docker_registry_image" "this" {
  count = var.create ? 1 : 0

  name = var.create ? docker_image.this[0].name : "null"
  keep_remotely = false

  triggers = {
    dir_sha = local.docker_source_sha
  }
}

resource "aws_ecr_repository" "this" {
  count = var.create ? 1 : 0

  force_delete         = true
  name                 = local.ecr_repo

  #checkov:skip=CKV_AWS_51: ECR Image Tags are immutable with an Exclusion
  image_tag_mutability = "IMMUTABLE_WITH_EXCLUSION"
  image_tag_mutability_exclusion_filter {
    filter      = "latest*"
    filter_type = "WILDCARD"
  }

  image_scanning_configuration {
    scan_on_push = true
  }
  
  encryption_configuration {
    encryption_type = "KMS"  
  }

  tags = var.tags
}

resource "aws_ecr_lifecycle_policy" "this" {
  count = var.create ? 1 : 0

  policy = jsonencode({
    "rules" : [
      {
        "rulePriority" : 1,
        "description" : "Keep only the last 2 images",
        "selection" : {
          "tagStatus" : "any",
          "countType" : "imageCountMoreThan",
          "countNumber" : 2
        },
        "action" : {
          "type" : "expire"
        }
      }
    ]
  })
  repository = var.create ? aws_ecr_repository.this[0].name: "null"
}