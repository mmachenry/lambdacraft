variable "aws_region" {
  description = "The region to provision resources in."
  default     = "us-east-1"
  type        = string
}

variable "log_retention" {
  description = "Duration in days to retain logs."
  default     = 14
  type        = number
}

variable "game_vm_type" {
  description = "EC2 machine type on which to run the game server."
  # TODO: Determine if we can use the non-x86 t4g instances instead.
  default = "t3.large"
  type    = string
}

variable "ecs_cluster_name" {
  description = "Name of the AWS ECS cluster. Separated to break a cycle."
  default     = "game-cluster"
  type        = string
}
