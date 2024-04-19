provider "aws" {
  region = local.region
}




locals {
  region = "eu-west-1"
  name   = "celery"

  container_name = "celery-container"

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
  source = "../../../terraform/deps/cluster"

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
  source = "../../../terraform/deps/service"

  name        = "${local.name}-standalone"
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
      image = "647017618515.dkr.ecr.eu-west-1.amazonaws.com/celery:latest"
      readonly_root_filesystem = false
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]

      workingDirectory = "/app"
      entrypoint = ["/bin/sh", "-c"]
      command    = ["echo 'markel'"]
      # command    = ["redis-server & celery --app=src.init.celery worker --uid=nobody --gid=nogroup & python3 src/init.py"]
      # command    = ["echo 'markel'"]
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
}

resource "aws_ecr_repository" "app_ecr_repo" {
  name = local.name
}
