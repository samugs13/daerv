resource "google_compute_network" "attacker_network" {
  project                 = var.project_id
  name                    = "attacker-network"
  mtu                     = 1460
  auto_create_subnetworks = false
}

resource "google_compute_router" "attacker_router" {
  name    = "attacker-router"
  network = google_compute_network.attacker_network.self_link
  project = var.project_id

  bgp {
    asn               = 64512
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}

resource "google_compute_router_nat" "attacker_nat" {
  name                               = "attacker-nat"
  router                             = google_compute_router.attacker_router.name
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_subnetwork" "attacker_lan" {
  name          = "attacker-lan"
  ip_cidr_range = var.private_subnet_cidr_blocks[1]
  region        = var.region
  network       = google_compute_network.attacker_network.self_link
}

resource "google_compute_instance" "attacker" {
  name         = "attacker"
  machine_type = var.machine_type
  project      = var.project_id
  zone         = var.zone
  tags         = ["ssh"]

  boot_disk {
    initialize_params {
      image = var.debian_image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.attacker_lan.self_link
  }
}
