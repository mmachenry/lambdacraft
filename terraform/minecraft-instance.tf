# Resources used by the VM that runs Minecraft.

resource "google_compute_instance" "minecraft" {
  name         = "minecraft-instance"
  machine_type = var.minecraft_instance_type
  zone = var.zone
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = data.google_compute_image.cos.self_link
    }
  }

  network_interface {
    network = google_compute_network.vpc.self_link
    access_config { }
  }

  metadata = {
    # The "env" bit below can be axed once we're using a custom image.
    gce-container-declaration = <<-EOT
      spec:
        restartPolicy: Never
        volumes:
        - name: pd-0
          gcePersistentDisk:
            pdName: ${google_compute_disk.persistence_disk.name}
            fsType: ext4
            partition: 0
        containers:
        - name: minecraft-server
          image: ${var.minecraft_image}
          imagePullPolicy: Always
          volumeMounts:
          - name: pd-0
            mountPath: /data
          env:
          - name: EULA
            value: TRUE
      EOT
  }

  attached_disk {
    source = google_compute_disk.persistence_disk.self_link
    device_name = google_compute_disk.persistence_disk.name
  }

  service_account {
    email = google_service_account.minecraft_account.email
    scopes = []
  }
}

resource "google_compute_disk" "persistence_disk" {
  name = "minecraft-persistence"
  zone = var.zone
  type = "pd-standard"
  size = 10
}
