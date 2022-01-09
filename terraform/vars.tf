variable "aws_region" {
  default = "us-east-1"
  description = "The region to provision resources in."
  type = string
}

variable "log_retention" {
  default = 14
  description = "Duration in days to retain logs."
  type = number
}