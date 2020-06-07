variable "project" {
  description = "GCP project where the Minecraft server will be run."
}

variable "region" {
  description = "GCP region in which to run resources."
  default = "us-central1"
}

variable "zone" {
  description = "GCP zone in which to run resources. If it's not within the specified region, you're gonna have a bad time."
  default = "us-central1-c"
}

variable "domain_name" {
  description = "Host name players will use to connect to the server."
}

variable "minecraft_instance_type" {
  description = "GCP instance type to use for the VM running Minecraft."
  default = "e2-standard-2"
}

variable "credentials_file" { }
