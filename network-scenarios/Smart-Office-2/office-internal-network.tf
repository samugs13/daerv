resource "google_compute_network" "office_internal_network" {
  project                 = var.project_id
  name                    = "office-internal-network"
  mtu                     = 1460
  auto_create_subnetworks = false
}

resource "google_compute_router" "internal_router" {
  name    = "internal-router"
  network = google_compute_network.office_internal_network.self_link
  project = var.project_id

  bgp {
    asn               = 64514
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}

resource "google_compute_router_nat" "internal_nat" {
  name                               = "internal-nat"
  router                             = google_compute_router.internal_router.name
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_subnetwork" "office_internal_lan" {
  name          = "employees-lan"
  ip_cidr_range = var.private_subnet_cidr_blocks[0]
  region        = var.region
  network       = google_compute_network.office_internal_network.self_link
}

resource "google_compute_subnetwork" "smart_speaker_lan" {
  name          = "printer-lan"
  ip_cidr_range = var.private_subnet_cidr_blocks[1]
  region        = var.region
  network       = google_compute_network.office_internal_network.self_link
}

resource "google_compute_instance" "employee_pc_1" {
  name         = "employee-pc-1"
  machine_type = var.machine_type
  project      = var.project_id
  zone         = var.zone
  tags         = ["employee"]

  boot_disk {
    initialize_params {
      image = var.ubuntu_image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.office_internal_lan.self_link
  }
}

resource "google_compute_instance" "employee_pc_2" {
  name         = "employee-pc-2"
  machine_type = var.machine_type
  project      = var.project_id
  zone         = var.zone
  tags         = ["employee"]

  boot_disk {
    initialize_params {
      image = var.ubuntu_image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.office_internal_lan.self_link
  }
}

resource "google_compute_instance" "smart_speaker_hub" {
  name         = "smart-speaker-hub"
  machine_type = var.machine_type
  project      = var.project_id
  zone         = var.zone
  tags         = ["ssh", "speaker-hub"]

  boot_disk {
    initialize_params {
      image = var.debian_image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.office_internal_lan.self_link
  }
}

resource "google_compute_instance" "smart_speaker_1" {
  name         = "smart-speaker-1"
  machine_type = var.machine_type
  project      = var.project_id
  zone         = var.zone
  tags         = ["ssh", "speaker"]

  boot_disk {
    initialize_params {
      image = var.container_image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.smart_speaker_lan.self_link
  }
}

resource "google_compute_instance" "smart_speaker_2" {
  name         = "smart-speaker-2"
  machine_type = var.machine_type
  project      = var.project_id
  zone         = var.zone
  tags         = ["ssh", "speaker"]

  boot_disk {
    initialize_params {
      image = var.container_image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.smart_speaker_lan.self_link
  }
}

resource "google_compute_instance" "smart_speaker_3" {
  name         = "smart-speaker-3"
  machine_type = var.machine_type
  project      = var.project_id
  zone         = var.zone
  tags         = ["ssh", "speaker"]

  boot_disk {
    initialize_params {
      image = var.container_image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.smart_speaker_lan.self_link
  }
}
