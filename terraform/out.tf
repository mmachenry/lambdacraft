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
