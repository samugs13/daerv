provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network_peering" "peer_attacker_to_home" {
  name         = "peer-attacker-to-home"
  network      = google_compute_network.attacker_network.self_link
  peer_network = google_compute_network.smart_home.self_link
}

resource "google_compute_network_peering" "peer_home_to_attacker" {
  name         = "peer-home-to-attacker"
  network      = google_compute_network.smart_home.self_link
  peer_network = google_compute_network.attacker_network.self_link
}

resource "google_compute_firewall" "allow-ssh-home" {
  name     = "allow-ssh-home"
  network  = google_compute_network.smart_home.self_link
  project  = var.project_id
  priority = 65534

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}

resource "google_compute_firewall" "allow-ssh-attacker" {
  name     = "allow-ssh-attacker"
  network  = google_compute_network.attacker_network.self_link
  project  = var.project_id
  priority = 65534

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}

resource "google_compute_firewall" "allow_internal" {
  name     = "allow-internal"
  network  = google_compute_network.smart_home.self_link
  project  = var.project_id
  priority = 1000

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [google_compute_subnetwork.home_lan.ip_cidr_range]
}

resource "google_compute_firewall" "allow_home_from_attacker" {
  name      = "allow-home-from-attacker"
  network   = google_compute_network.smart_home.self_link
  project   = var.project_id
  priority  = 1000
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [google_compute_subnetwork.attacker_lan.ip_cidr_range]
}

# resource "google_compute_firewall" "allow_attacker_from_home" {
#   name      = "allow-attacker-from-home"
#   network   = google_compute_network.smart_home.self_link
#   project   = var.project_id
#   priority  = 1000
#   direction = "INGRESS"
#
#   allow {
#     protocol = "tcp"
#     ports    = ["0-65535"]
#   }
#
#   allow {
#     protocol = "udp"
#     ports    = ["0-65535"]
#   }
#
#   allow {
#     protocol = "icmp"
#   }
#
#   source_ranges = [google_compute_subnetwork.home_lan.ip_cidr_range]
# }
