resource "aws_apigatewayv2_api" "game_management" {
  name          = "game_management"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "prod" {
  name        = "prod"
  api_id      = aws_apigatewayv2_api.game_management.id
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_apigatewayv2_integration" "start_server" {
  api_id                 = aws_apigatewayv2_api.game_management.id
  integration_uri        = aws_lambda_function.startup.invoke_arn
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "start_server" {
  api_id    = aws_apigatewayv2_api.game_management.id
  route_key = "GET /start_server"
  target    = "integrations/${aws_apigatewayv2_integration.start_server.id}"
}

resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/api_gw/${aws_apigatewayv2_api.game_management.name}"
  retention_in_days = var.log_retention
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.startup.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.game_management.execution_arn}/*/*"
}
