data "aws_ec2_instance_type" "game" {
  instance_type = var.game_vm_type
}

data "aws_ami" "amazn2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "manifest-location"
    values = ["amazon/amzn2-ami-ecs-*"]
  }

  filter {
    name   = "architecture"
    values = [data.aws_ec2_instance_type.game.supported_architectures[0]]
  }
}

resource "aws_launch_template" "game" {
  name_prefix            = "game_"
  image_id               = data.aws_ami.amazn2.id
  instance_type          = var.game_vm_type
  vpc_security_group_ids = [aws_security_group.game.id]
  ebs_optimized          = true
  instance_market_options {
    market_type = "spot"
  }
  # TODO: Don't hard-code this, or at least ensure it's been created.
  iam_instance_profile {
    name = "ecsInstanceRole"
  }
  # ECS requires this because ECS be crazy.
  user_data = base64encode("#!/bin/bash\necho ECS_CLUSTER=${var.ecs_cluster_name} >> /etc/ecs/ecs.config;")
}

resource "aws_autoscaling_group" "game" {
  name = "game"
  # So long as this subnet is hardcoded, we gain no benefit from multiple AZs.
  vpc_zone_identifier   = [aws_subnet.subnet_a.id]
  protect_from_scale_in = true

  desired_capacity = 0
  min_size         = 0
  max_size         = 1

  launch_template {
    id      = aws_launch_template.game.id
    version = aws_launch_template.game.latest_version
  }

  # This is automatically added by the ECS capacity provider, so we need to
  # include it here to prevent a false diff.
  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}

resource "aws_ecs_capacity_provider" "game" {
  name = "Lambdacraft-Game-Cluster-Capacity-Provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.game.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      status                    = "ENABLED"
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 1
      target_capacity           = 100
    }
  }
}

resource "aws_iam_policy" "game_task" {
  name   = "lambdacraft-game-service-policy"
  policy = data.aws_iam_policy_document.actions.json
}

data "aws_iam_policy_document" "actions" {
  statement {
    actions = [
      "application-autoscaling:*",
      "ecs:DescribeServices",
      "ecs:UpdateService",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:DeleteAlarms",
      "cloudwatch:DescribeAlarmHistory",
      "cloudwatch:DescribeAlarmsForMetric",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics",
      "cloudwatch:DisableAlarmActions",
      "cloudwatch:EnableAlarmActions",
      "iam:CreateServiceLinkedRole",
      "sns:CreateTopic",
      "sns:Subscribe",
      "sns:Get*",
      "sns:List*"
    ]
    resources = ["*"]
  }
}

resource "aws_ecr_repository" "game" {
  name = "game-repository"
}

resource "aws_ecs_cluster" "game" {
  name               = var.ecs_cluster_name
  capacity_providers = [aws_ecs_capacity_provider.game.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.game.name
    weight            = 100
  }
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

resource "aws_iam_role_policy_attachment" "game_task" {
  role       = aws_iam_role.game_task.name
  policy_arn = aws_iam_policy.game_task.arn
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

  ingress {
    description = "ssh port"
    from_port   = 22
    to_port     = 22
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

resource "aws_backup_vault" "world" {
  name = "lambdacraft_backup_vault"
}

resource "aws_efs_mount_target" "world" {
  file_system_id  = aws_efs_file_system.world.id
  subnet_id       = aws_subnet.subnet_a.id
  security_groups = [aws_security_group.world_efs.id]
}

resource "aws_security_group" "world_efs" {
  name        = "Lambdacraft NSF world mount security group"
  description = "Allow NFS port ingress"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "NFS protocol ingress"
    from_port   = 2049
    to_port     = 2049
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
  family             = "game"
  task_role_arn      = aws_iam_role.game_task.arn
  execution_role_arn = aws_iam_role.ecs_task_execution.arn
  network_mode       = "host"
  # Reserve a little bit of capacity for the OS/other processes
  cpu                      = data.aws_ec2_instance_type.game.default_vcpus * 1024 - 128
  memory                   = data.aws_ec2_instance_type.game.memory_size - 1024
  requires_compatibilities = ["EC2"]
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
          sourceVolume  = "world"
        }
      ],
      environment = [
        {
          name  = "ENABLE_RCON",
          value = "true"
        },
        {
          name  = "RCON_PASSWORD",
          value = var.rcon_password
        },
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
