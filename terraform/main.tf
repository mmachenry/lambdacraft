provider "google" {
  version = "3.24.0"

  credentials = file(var.credentials_file)

  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "vpc_network" {
  name = "minecraft-network"
}

resource "google_compute_instance" "minecraft_instance" {
  name         = "minecraft-instance"
  machine_type = var.minecraft_instance_type
  zone = var.zone

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.self_link
    access_config { }
  }

  metadata = {
    gce-container-declaration = <<-EOT
      spec:
        restartPolicy: Never
        volumes:
        - name: pd-0
          gcePersistentDisk:
            pdName: $(ref.lambdacraft-persistence.name)
            fsType: ext4
            partition: 0
        containers:
        - name: minecraft-server
          image: us.gcr.io/minecraft-experimentation/lambdacraft
          imagePullPolicy: Always
          volumeMounts:
          - name: pd-0
            mountPath: /data
      EOT
  }

  attached_disk {
    source = google_compute_disk.persistence_disk.self_link
  }
  # service_account
  # attached_disk
}

resource "google_compute_disk" "persistence_disk" {
  name = "minecraft-persistence"
  zone = var.zone
  type = "pd-standard"
  size = 10
}

resource "google_compute_instance" "standby_instance" {
  name         = "standby-instance"
  machine_type = "e2-micro"
  zone = var.zone

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.self_link
    access_config {
      nat_ip = google_compute_address.standby_ip.address
    }
  }

  scheduling {
    preemptible = true
    automatic_restart = false
  }
}

resource "google_compute_address" "standby_ip" {
  name = "terraform-static-ip"
}

# Container Registry
# GCS (for terraform state storage)
# DNS config
# GCE autoscaling group