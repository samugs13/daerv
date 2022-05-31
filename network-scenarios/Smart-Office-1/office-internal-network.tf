resource "google_compute_network" "office_internal_network" {
  project                 = var.project_id
  name                    = "office-internal-network"
  mtu                     = 1460
  auto_create_subnetworks = false
}

resource "google_compute_router" "office_internal_router" {
  name    = "office-internal-router"
  network = google_compute_network.office_internal_network.self_link
  project = var.project_id

  bgp {
    asn               = 64514
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}

resource "google_compute_router_nat" "office_internal_nat" {
  name                               = "office-internal-nat"
  router                             = google_compute_router.office_internal_router.name
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_subnetwork" "employees_lan" {
  name          = "employees-lan"
  ip_cidr_range = var.private_subnet_cidr_blocks[0]
  region        = var.region
  network       = google_compute_network.office_internal_network.self_link
}

resource "google_compute_subnetwork" "printer_lan" {
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
    subnetwork = google_compute_subnetwork.employees_lan.self_link
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
      image = var.windows_image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.employees_lan.self_link
  }
}

resource "google_compute_instance" "employee_pc_3" {
  name         = "employee-pc-3"
  machine_type = var.machine_type
  project      = var.project_id
  zone         = var.zone
  tags         = ["ssh", "employee"]

  boot_disk {
    initialize_params {
      image = var.ubuntu_image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.employees_lan.self_link
  }
}

resource "google_compute_instance" "office_printer" {
  name         = "office-printer"
  machine_type = var.machine_type
  project      = var.project_id
  zone         = var.zone
  tags         = ["ssh", "printer", "employee"]

  boot_disk {
    initialize_params {
      image = var.ubuntu_image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.printer_lan.self_link
  }
}
