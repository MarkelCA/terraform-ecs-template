provider "aws" {
  region = local.region
}


locals {
  region = "eu-west-1"
  name   = "ex-${basename(path.cwd)}"

  container_name = "ecsdemo-frontend"

  tags = {
    Name       = local.name
    Example    = local.name
    Repository = "https://github.com/terraform-aws-modules/terraform-aws-ecs"
  }
}

################################################################################
# Cluster
################################################################################

module "ecs_cluster" {
  source = "../../modules/cluster"

  cluster_name = local.name

  # Capacity provider
  fargate_capacity_providers = {
    # FARGATE = {
    #   default_capacity_provider_strategy = {
    #     weight = 50
    #     base   = 20
    #   }
    # }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  tags = local.tags
}

################################################################################
# Standalone Task Definition (w/o Service)
################################################################################

module "ecs_task_definition" {
  source = "../../modules/service"

  # Service
  name        = "${local.name}-standalone"
  cluster_arn = module.ecs_cluster.arn
  desired_count = 1

  # Task Definition
  volume = {
    ex-vol = {}
  }

  runtime_platform = {
    cpu_architecture        = "ARM64"
    operating_system_family = "LINUX"
  }

  # Container definition(s)
  container_definitions = {
    (local.container_name) = {
      essential = true
      desired_count = 0
      image = "public.ecr.aws/amazonlinux/amazonlinux:2023-minimal"
      # image = ${aws_ecr_repository.app_ecr_repo.repository_url}

      mount_points = [
        {
          sourceVolume  = "ex-vol",
          containerPath = "/var/www/ex-vol"
        }
      ]

      # command    = ["echo hello world"]
      command    = ["while :; do echo 'hi'; sleep 30; done"]
      entrypoint = ["/usr/bin/sh", "-c"]
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
  source = "../../vpc"
}

resource "aws_ecr_repository" "app_ecr_repo" {
  name = local.name
}
