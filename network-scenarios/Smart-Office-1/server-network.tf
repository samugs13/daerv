resource "google_compute_network" "server_network" {
  project                 = var.project_id
  name                    = "server-network"
  mtu                     = 1460
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "server_lan" {
  name          = "server-lan"
  ip_cidr_range = var.private_subnet_cidr_blocks[4]
  region        = var.region
  network       = google_compute_network.server_network.self_link
}

resource "google_compute_instance" "cloud_printer_server" {
  name         = "cloud-printer-server"
  machine_type = var.machine_type
  project      = var.project_id
  zone         = var.zone
  tags         = ["server"]

  boot_disk {
    initialize_params {
      image = var.ubuntu_image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.server_lan.self_link
    access_config {}
  }

  metadata_startup_script = templatefile(var.manual_provisioning_path, { args = "-p 80:80", image = "nginx", tag = "latest" })
}
