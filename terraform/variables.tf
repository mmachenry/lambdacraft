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

variable "minecraft_image" {
  description = "Docker image to be run on the Minecraft server VM."
  default = "itzg/minecraft-server"
}

variable "standby_image" {
  description = "Docker image to be run on the standby VM."
  default = "TDB"
}

# Convenience variables you probably don't want to override.
variable "gcp_service_list" {
  description = "List of GCP service to be enabled for a project."
  type        = list
  default = [
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "dns.googleapis.com",
  ]
}

variable "sa_roles" {
  description = "Roles to be granted to the Minecraft service account."
  type        = list
  default = [
    "roles/compute.instanceAdmin",
    "roles/dns.admin",
  ]
}