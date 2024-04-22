provider "aws" {
  region = local.region
}

data "aws_caller_identity" "current" {}


locals {
  region = "eu-west-1"
  name   = "markel-${basename(dirname(path.cwd))}"
  description = "This resource has been created as part of a smowlkathon"

  container_name = "${local.name}-container"

  tags = {
    Name = local.name
    Description = local.description
    Repository = "https://github.com/terraform-aws-modules/terraform-aws-ecs"
  }
}

################################################################################
# Cluster
################################################################################

module "ecs_cluster" {
  source = "../../../terraform/deps/cluster"

  cluster_name = local.name

  # Capacity provider
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
        base   = 20
      }
    }
    # FARGATE_SPOT = {
    #   default_capacity_provider_strategy = {
    #     weight = 50
    #   }
    # }
  }

  tags = local.tags
}

################################################################################
# Standalone Task Definition (w/o Service)
################################################################################

module "ecs_task_definition" {
  source = "../../../terraform/deps/service"
  create_service = false

  name        = "${local.name}"
  cluster_arn = module.ecs_cluster.arn
  desired_count = 0

  runtime_platform = {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  # Container definition(s)
  container_definitions = {
    (local.container_name) = {
      essential = true
      # image = "public.ecr.aws/amazonlinux/amazonlinux:2023-minimal"
      image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${local.region}.amazonaws.com/${local.name}:latest"
      readonly_root_filesystem = false
      workingDirectory = "/app"
      environment = [
        {
          name = "MY_SECRET_KEY"
          value = "my_secret_value"
        }
      ]

    }
  }

  subnet_ids = module.vpc.private_subnets

  security_group_rules = {
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = local.tags
}

################################################################################
# Supporting Resources
################################################################################
module "vpc" {
  source = "../../../terraform/vpc"
  name = local.name
}

resource "aws_ecr_repository" "app_ecr_repo" {
  name = local.name
  tags = local.tags
}
