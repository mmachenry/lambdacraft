resource "aws_ecr_repository" "game" {
  name = "game-repository"
}

resource "aws_ecs_cluster" "game" {
  name = "game-cluster"
}

resource "aws_iam_role" "game_task" {
  name = "game-task-role"
  assume_role_policy = data.aws_iam_policy_document.game_task.json
}

data "aws_iam_policy_document" "game_task" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }   
  }
}

resource "aws_iam_role_policy_attachment" "game_task" {
  for_each = toset([
  ])  
  role = aws_iam_role.game_task.name
  policy_arn = each.value
}

resource "aws_cloudwatch_log_group" "game" {
  name = "game-task"
}

resource "aws_ecs_task_definition" "game" {
  family = "game"
  task_role_arn = aws_iam_role.game_task.arn
  execution_role_arn = aws_iam_role.ecs_task_execution.arn
  network_mode = "awsvpc"
  cpu = "4096"
  memory = "30720"
  requires_compatibilities = ["FARGATE"]
  container_definitions = <<DEFINITION
[
  {
    "name": "game-container",
    "image": "${aws_ecr_repository.game.repository_url}:latest",
    "environment": [
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.game.name}",
        "awslogs-region": "${var.aws_region}",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "cpu": 0,
    "essential": true
  }
]
DEFINITION
}