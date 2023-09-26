output "game_repository_url" {
  value = aws_ecr_repository.game.repository_url
}

output "base_url" {
  description = "Base URL for API Gateway."
  value       = aws_apigatewayv2_stage.prod.invoke_url
}

output "game_cluster_arn" {
  value = aws_ecs_cluster.game.arn
}

output "game_task_definition_arn" {
  value = aws_ecs_task_definition.game.arn
}

output "world_efs_arn" {
  value = aws_efs_file_system.world.arn
}

output "world_efs_mount_target_dns_name" {
  value = aws_efs_mount_target.world
}

output "new_world_efs_mount_target_dns_name" {
  value = aws_efs_mount_target.new_world
}
