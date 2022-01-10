data "aws_ami" "amazn2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "manifest-location"
    values = ["amazon/amzn2-ami-kernel-5.10-hvm-*"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"] # TODO: Determine this by EC2 machine type.
  }
}

resource "aws_launch_template" "game" {
  name_prefix            = "game_"
  image_id               = data.aws_ami.amazn2.id
  instance_type          = var.game_vm_type
  vpc_security_group_ids = [aws_security_group.game.id]
}

resource "aws_autoscaling_group" "game" {
  name                = "game"
  vpc_zone_identifier = [aws_subnet.subnet_a.id]

  desired_capacity = 0
  min_size         = 0
  max_size         = 1

  launch_template {
    id = aws_launch_template.game.id
  }
}

resource "aws_ecs_capacity_provider" "game" {
  name = "Lambdacraft-Game-Cluster-Capacity-Provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.game.arn

    managed_scaling {
      status = "ENABLED"
    }
  }
}

resource "aws_ecs_service" "game" {
  name            = "Lambdacraft-ECS-Service"
  cluster         = aws_ecs_cluster.game.id
  task_definition = aws_ecs_task_definition.game.arn
  desired_count   = 0

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.game.arn
    weight            = 100
  }

  network_configuration {
    subnets          = [ aws_subnet.subnet_a.id, aws_subnet.subnet_b.id, aws_subnet.subnet_c.id ]
    security_groups  = [aws_security_group.game.id]
  }
}

resource "aws_ecr_repository" "game" {
  name = "game-repository"
}

resource "aws_ecs_cluster" "game" {
  name               = "game-cluster"
  capacity_providers = [aws_ecs_capacity_provider.game.name]
}

resource "aws_iam_role" "game_task" {
  name               = "game-task-role"
  assume_role_policy = data.aws_iam_policy_document.game_task.json
}

data "aws_iam_policy_document" "game_task" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "game_task" {
  for_each = toset([
  ])
  role       = aws_iam_role.game_task.name
  policy_arn = each.value
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
  cpu                      = "4096"
  memory                   = "30720"
  requires_compatibilities = ["EC2"]
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
    }
  ])
}
