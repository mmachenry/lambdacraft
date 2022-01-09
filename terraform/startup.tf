data "aws_iam_policy_document" "startup_lambda_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "startup_lambda" {
  name               = "report_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.startup_lambda_assume_role.json
}

resource "aws_cloudwatch_log_group" "startup_lambda" {
  name              = "/aws/lambda/${aws_lambda_function.startup.function_name}"
  retention_in_days = var.log_retention
}

data "aws_iam_policy_document" "startup_lambda" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
    ]
    resources = [aws_cloudwatch_log_group.startup_lambda.arn]
  }

  statement {
    effect    = "Allow"
    actions   = ["logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.startup_lambda.arn}:*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecs:RunTask",
    ]
    resources = [
      aws_ecs_task_definition.game.arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole",
    ]
    resources = [
      aws_iam_role.ecs_task_execution.arn,
      aws_iam_role.game_task.arn
    ]
  }
}

resource "aws_iam_role_policy" "startup_lambda" {
  name   = "startup_lambda_policy"
  policy = data.aws_iam_policy_document.startup_lambda.json
  role   = aws_iam_role.startup_lambda.id
}

data "archive_file" "startup_lambda" {
  type        = "zip"
  source_file = "${path.module}/startup/lambda_handler.py"
  output_path = "${path.module}/startup/lambda_handler.zip"
}

resource "aws_lambda_function" "startup" {
  function_name    = "startup_lambda"
  filename         = data.archive_file.startup_lambda.output_path
  handler          = "lambda_handler.handler"
  source_code_hash = data.archive_file.startup_lambda.output_base64sha256
  runtime          = "python3.8"
  role             = aws_iam_role.startup_lambda.arn
  environment {
    variables = {
      CLUSTER_ARN = aws_ecs_cluster.game.arn,
      TASK_ARN    = aws_ecs_task_definition.game.arn,
      SUBNET_IDS  = "${aws_subnet.subnet_a.id},${aws_subnet.subnet_b.id},${aws_subnet.subnet_c.id}"
      SECURITY_GROUP_ID = aws_security_group.game.id,
    }
  }
}