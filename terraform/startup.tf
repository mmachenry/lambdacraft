# Location for the terraform code related to server startup.

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
  name               = "startup_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.startup_lambda_assume_role.json
}

resource "aws_cloudwatch_log_group" "startup_lambda" {
  name              = "/aws/lambda/${aws_lambda_function.startup.function_name}"
  retention_in_days = var.log_retention
}

data "aws_iam_policy_document" "startup_lambda" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }

  statement {
    actions = [
      "ecs:RunTask",
    ]
    resources = [
      aws_ecs_task_definition.game.arn
    ]
  }

  statement {
    actions = [
      "ecs:ListTasks",
      "ecs:DescribeTasks",
      "ecs:DescribeContainerInstances",
      "ec2:DescribeInstances",
    ]
    resources = ["*"]
  }

  statement {
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
  source_file = "${path.module}/lambdas/startup.py"
  output_path = "${path.module}/lambdas/startup.zip"
}

resource "aws_lambda_function" "startup" {
  # TODO: source_code_hash appears to change when generated by different people, but it shouldn't.
  function_name    = "startup_lambda"
  filename         = data.archive_file.startup_lambda.output_path
  handler          = "startup.handler"
  source_code_hash = data.archive_file.startup_lambda.output_base64sha256
  runtime          = "python3.8"
  role             = aws_iam_role.startup_lambda.arn
  environment {
    variables = {
      CLUSTER_ARN       = aws_ecs_cluster.game.arn,
      TASK_ARN          = aws_ecs_task_definition.game.arn,
      SUBNET_IDS        = "${aws_subnet.subnet_a.id},${aws_subnet.subnet_b.id}"
      SECURITY_GROUP_ID = aws_security_group.game.id,
    }
  }
}
