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
  default     = "t4g.large"
  type        = string
}
