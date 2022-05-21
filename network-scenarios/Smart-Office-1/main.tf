provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network_peering" "peering_1" {
  name         = "peering-1"
  network      = google_compute_network.office_internal_network.self_link
  peer_network = google_compute_network.office_external_network.self_link
}

resource "google_compute_network_peering" "peering_2" {
  name         = "peering-2"
  network      = google_compute_network.office_external_network.self_link
  peer_network = google_compute_network.office_internal_network.self_link
}

resource "google_compute_network_peering" "peering_3" {
  name         = "peering-3"
  network      = google_compute_network.office_internal_network.self_link
  peer_network = google_compute_network.server_network.self_link
}

resource "google_compute_network_peering" "peering_4" {
  name         = "peering-4"
  network      = google_compute_network.server_network.self_link
  peer_network = google_compute_network.office_internal_network.self_link
}

resource "google_compute_firewall" "allow_ssh_internal" {
  name     = "allow-ssh-internal"
  network  = google_compute_network.office_internal_network.self_link
  project  = var.project_id
  priority = 900

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}

resource "google_compute_firewall" "allow_icmp_internal" {
  name     = "allow-icmp-internal"
  network  = google_compute_network.office_internal_network.self_link
  project  = var.project_id
  priority = 900

  allow {
    protocol = "icmp"
  }

  source_ranges = [google_compute_subnetwork.office_internal_lan.ip_cidr_range]
}

resource "google_compute_firewall" "allow_ssh_external" {
  name     = "allow-ssh-external"
  network  = google_compute_network.office_external_network.self_link
  project  = var.project_id
  priority = 900

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}

resource "google_compute_firewall" "allow_icmp_external" {
  name     = "allow-icmp-external"
  network  = google_compute_network.office_external_network.self_link
  project  = var.project_id
  priority = 900

  allow {
    protocol = "icmp"
  }

  source_ranges = [google_compute_subnetwork.office_external_lan.ip_cidr_range]
}
