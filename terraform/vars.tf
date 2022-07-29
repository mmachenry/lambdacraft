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

variable "rcon_password" {
  description = "The password to login to admin the server with RCON."
  default     = "Lambdacraft"
  type        = string
}

variable "hostname" {
  description = "Hostname players use to connect to the server."
  default     = "heckbringer.com"
  type        = string
}

variable "hosted_zone_id" {
  description = "Hosted zone within which to maintain DNS records for the server."
  default     = "ZOQDXS6QXD97N"
  type        = string
}
