# This module contains all the networking resources needed for our Minecraft instance.

resource "google_compute_network" "vpc" {
  name = "minecraft-network"
}

resource "google_compute_firewall" "firewall" {
  name    = "minecraft-firewall"
  network = google_compute_network.vpc.self_link

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "25565", "25575"]
  }
}

resource "google_dns_managed_zone" "zone" {
  name     = "minecraft-zone"
  dns_name = "${var.domain_name}."
}

resource "google_compute_address" "standby_ip" {
  name = "terraform-static-ip"
}
