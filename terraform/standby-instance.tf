# Resources used by the VM running the standby service.

resource "google_compute_instance_template" "standby_template" {
  # Can't use "name" or this can't be updated.
  name_prefix = "standby-template"
  machine_type   = "e2-micro"
  can_ip_forward = false  # May want to look further into this.

  # Needed to allow changes.
  lifecycle {
    create_before_destroy = true
  }

  disk {
    source_image = data.google_compute_image.cos.self_link
  }

  network_interface {
    network = google_compute_network.vpc.self_link
    access_config {
      nat_ip = google_compute_address.standby_ip.address
    }
  }

  service_account {
    email = google_service_account.minecraft_account.email
    scopes = []
  }

  scheduling {
    preemptible = true
    automatic_restart = false
  }
}

resource "google_compute_target_pool" "standby_pool" {
  name = "standby-target-pool"
}

resource "google_compute_instance_group_manager" "standby_igm" {
  name = "standby-igm"
  zone = var.zone

  version {
    name               = "primary"
    instance_template  = google_compute_instance_template.standby_template.id
  }

  target_pools       = [google_compute_target_pool.standby_pool.id]
  base_instance_name = "standby"
}

resource "google_compute_autoscaler" "standby_autoscaler" {
  name   = "standby-autoscaler"
  zone   = var.zone
  target = google_compute_instance_group_manager.standby_igm.id

  autoscaling_policy {
    max_replicas    = 1
    min_replicas    = 1
  }
}
