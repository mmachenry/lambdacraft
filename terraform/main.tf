# Contains the common Terraform resources needed by our Minecraft instance.

provider "google" {
  version = "3.25.0"

  project = var.project
  region  = var.region
  zone    = var.zone
}

terraform {
  backend "gcs" {
    # Can't use a variable here since this runs before all other Terraform code.
    bucket  = "lambdacraft-test-terraform-state"
  }
}

# Note - since this bucket stores Terraform state, it needs to be initialized prior to the rest of
# the infrastructure. It probably shouldn't be managed by Terraform for that reason, but I don't
# know what I'm doing!
resource "google_storage_bucket" "terraform_state" {
  name          = "${var.project}-terraform-state"
  location      = "US"
  force_destroy = true
  bucket_policy_only = true
  versioning {
    enabled = true
  }
}

# Enable needed APIs. Note this doesn't currently work, as cloudresourcemanager.googleapis.com
# seems to need to be enabled first.
resource "google_project_service" "apis" {
  count   = length(var.gcp_service_list)
  service = var.gcp_service_list[count.index]
  disable_dependent_services = true
}

# Create a bucket for the service registry. This isn't actually needed unless we want to explicitly
# grant access to this to a service account, as the bucket is created automatically when pushed to.
resource "google_container_registry" "registry" {
  location = "US"
}

# Image used by all our VMs.
data "google_compute_image" "cos" {
  family  = "cos-stable"
  project = "cos-cloud"
}

resource "google_service_account" "minecraft_account" {
  account_id  = "minecraft-service-account"
  description = "Used by all Minecraft VM resources."
}

# It would be nice if we could limit this further. Maybe a custom role?
resource "google_project_iam_member" "iam_compute" {
  count   = length(var.sa_roles)
  role    = var.sa_roles[count.index]
  member  = "serviceAccount:${google_service_account.minecraft_account.email}"
}
