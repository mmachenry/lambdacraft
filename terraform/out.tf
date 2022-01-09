output "game_repository_url" {
  value = aws_ecr_repository.game.repository_url
}

output "base_url" {
  description = "Base URL for API Gateway."
  value = aws_apigatewayv2_stage.prod.invoke_url
}