################################################################################
# Cluster
################################################################################

output "cluster_arn" {
  description = "ARN that identifies the cluster"
  value       = module.ecs_cluster.arn
}

output "cluster_id" {
  description = "ID that identifies the cluster"
  value       = module.ecs_cluster.id
}

output "cluster_name" {
  description = "Name that identifies the cluster"
  value       = module.ecs_cluster.name
}

output "cluster_capacity_providers" {
  description = "Map of cluster capacity providers attributes"
  value       = module.ecs_cluster.cluster_capacity_providers
}

output "cluster_autoscaling_capacity_providers" {
  description = "Map of capacity providers created and their attributes"
  value       = module.ecs_cluster.autoscaling_capacity_providers
}

output "ecr_public_url" {
  description = "ECR Public URL"
  value = aws_ecr_repository.app_ecr_repo.repository_url
}

################################################################################
# Standalone Task Definition (w/o Service)
################################################################################
# aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 647017618515.dkr.ecr.eu-west-1.amazonaws.com
output "push_docker_image_command" {
    description = "awscli command to push the docker image to ECR"
    value       = <<EOT
      aws ecr get-login-password --region ${local.region} | docker login --username AWS --password-stdin ${aws_ecr_repository.app_ecr_repo.repository_url} && \
      docker build -t ${local.name} . && \
      docker tag ${local.name}:latest ${aws_ecr_repository.app_ecr_repo.repository_url}:latest && \
      docker push ${aws_ecr_repository.app_ecr_repo.repository_url}:latest
  EOT
}

output "task_definition_run_task_command" {
  description = "awscli command to run the standalone task"
  value       = <<EOT
    aws ecs run-task --cluster ${module.ecs_cluster.name} \
      --task-definition ${module.ecs_task_definition.task_definition_family_revision} \
      --network-configuration "awsvpcConfiguration={subnets=[${join(",", module.vpc.private_subnets)}],securityGroups=[${module.ecs_task_definition.security_group_id}]}" \
      --region ${local.region}
  EOT
}
