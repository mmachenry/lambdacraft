resource "aws_ecr_repository" "game" {
  name = "game-repository"
}

resource "aws_ecs_cluster" "game" {
  name = var.ecs_cluster_name
}

resource "aws_iam_role" "game_task" {
  name               = "gameTaskRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_cloudwatch_log_group" "game" {
  name              = "game-task"
  retention_in_days = var.log_retention
}

resource "aws_security_group" "game" {
  name        = "Lambdacraft Game Server Security Group"
  description = "Allows Minecraft protocol inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Minecraft protocol standard port"
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Minecraft RCON standard port"
    from_port   = 25575
    to_port     = 25575
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_efs_file_system" "world" {
}

resource "aws_efs_mount_target" "world" {
  file_system_id  = aws_efs_file_system.world.id
  subnet_id       = aws_subnet.subnet_a.id
  security_groups = [aws_security_group.world_efs.id]
}

resource "aws_security_group" "world_efs" {
  name = "Lambdacraft NSF world mount security group"
  description = "Allow NFS port ingress"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "NFS protocol ingress"
    from_port = 2049
    to_port = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_task_definition" "game" {
  family                   = "game"
  task_role_arn            = aws_iam_role.game_task.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  network_mode             = "awsvpc"
  cpu                      = "2048"
  memory                   = "8192"
  requires_compatibilities = ["FARGATE"]
  # Avoiding a false diff
  tags = {}
  container_definitions = jsonencode([
    {
      name  = "game-container"
      image = "${aws_ecr_repository.game.repository_url}:latest"
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.game.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
      cpu       = 0
      essential = true
      mountPoints = [
        {
          containerPath = "/data",
          sourceVolume = "world"
        }
      ],
    }
  ])
  volume {
    name = "world"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.world.id
      root_directory = "/"
    }
  }
}
