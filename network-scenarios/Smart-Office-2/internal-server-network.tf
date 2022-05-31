resource "google_compute_network" "internal_server_network" {
  project                 = var.project_id
  name                    = "server-network"
  mtu                     = 1460
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "speaker_server_lan" {
  name          = "speaker-server-lan"
  ip_cidr_range = var.private_subnet_cidr_blocks[2]
  region        = var.region
  network       = google_compute_network.internal_server_network.self_link
}

resource "google_compute_instance" "smart_speaker_cloud_server" {
  name         = "smart-speaker-cloud-server"
  machine_type = var.machine_type
  project      = var.project_id
  zone         = var.zone
  tags         = ["ssh", "server"]

  boot_disk {
    initialize_params {
      image = var.ubuntu_image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.speaker_server_lan.self_link
  }
}
