provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "smart_office_1" {
  project                 = var.project_id
  name                    = "smart-office-1"
  mtu                     = 1460
  auto_create_subnetworks = false
}

resource "google_compute_firewall" "web_fw" {
  name     = "web-fw"
  network  = google_compute_network.smart_office_1.self_link
  project  = var.project_id
  priority = 900

  allow {
    protocol = "tcp"
    ports    = [80, 443]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["webserver"]
}

resource "google_compute_firewall" "ssh_fw" {
  name     = "ssh-fw"
  network  = google_compute_network.smart_office_1.self_link
  project  = var.project_id
  priority = 900

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}

resource "google_compute_firewall" "icmp_fw" {
  name     = "icmp-fw"
  network  = google_compute_network.smart_office_1.self_link
  project  = var.project_id
  priority = 900

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "internal_fw" {
  name     = "internal-fw"
  network  = google_compute_network.smart_office_1.self_link
  project  = var.project_id
  priority = 900

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  source_tags = ["internal"]
  target_tags = ["internal"]
}

resource "google_compute_router" "router" {
  name    = "router"
  network = google_compute_network.smart_office_1.self_link
  project = var.project_id

  bgp {
    asn               = 64514
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
    advertised_ip_ranges {
      range = "1.2.3.4"
    }
    advertised_ip_ranges {
      range = "6.7.0.0/16"
    }
  }
}

resource "google_compute_router_nat" "nat" {
  name                               = "nat"
  router                             = google_compute_router.router.name
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_subnetwork" "office_internal_lan" {
  name          = "office-internal-lan"
  ip_cidr_range = var.private_subnet_cidr_blocks[1]
  region        = var.region
  network       = google_compute_network.smart_office_1.self_link
}

resource "google_compute_subnetwork" "dmz" {
  name          = "dmz"
  ip_cidr_range = var.private_subnet_cidr_blocks[2]
  region        = var.region
  network       = google_compute_network.smart_office_1.self_link
}

resource "google_compute_subnetwork" "office_external_lan" {
  name          = "office-external-lan"
  ip_cidr_range = var.private_subnet_cidr_blocks[3]
  region        = var.region
  network       = google_compute_network.smart_office_1.self_link
}

resource "google_compute_subnetwork" "server_lan" {
  name          = "server-lan"
  ip_cidr_range = var.private_subnet_cidr_blocks[4]
  region        = var.region
  network       = google_compute_network.smart_office_1.self_link
}

resource "google_compute_instance" "employee_pc_1" {
  name         = "employee-pc-1"
  machine_type = var.machine_type
  project      = var.project_id
  zone         = var.zone
  tags         = ["ssh"]

  boot_disk {
    initialize_params {
      image = var.windows_image
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
  tags         = ["ssh"]

  boot_disk {
    initialize_params {
      image = var.windows_image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.office_internal_lan.self_link
  }
}

resource "google_compute_instance" "employee_pc_3" {
  name         = "employee-pc-3"
  machine_type = var.machine_type
  project      = var.project_id
  zone         = var.zone
  tags         = ["ssh"]

  boot_disk {
    initialize_params {
      image = var.windows_image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.office_internal_lan.self_link
  }
}

resource "google_compute_instance" "office_printer" {
  name         = "office-printer"
  machine_type = var.machine_type
  project      = var.project_id
  zone         = var.zone
  tags         = ["ssh"]

  boot_disk {
    initialize_params {
      image = var.ubuntu_image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.office_internal_lan.self_link
  }

  metadata_startup_script = templatefile(var.manual_provisioning_path, { args = "-p 80:80", image = "nginx", tag = "latest" })
}

resource "google_compute_instance" "ips" {
  name         = "ips"
  machine_type = var.machine_type
  project      = var.project_id
  zone         = var.zone
  tags         = ["ssh"]

  boot_disk {
    initialize_params {
      image = var.centos_image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.dmz.self_link
  }

  metadata_startup_script = templatefile(var.manual_provisioning_path, { args = "-p 80:80", image = "nginx", tag = "latest" })
}

resource "google_compute_instance" "cloud_printer_server" {
  name         = "cloud-printer-server"
  machine_type = var.machine_type
  project      = var.project_id
  zone         = var.zone
  tags         = ["ssh", "webserver"]

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

resource "google_compute_instance" "employee_remote_pc" {
  name         = "employee-remote-pc"
  machine_type = var.machine_type
  project      = var.project_id
  zone         = var.zone
  tags         = ["ssh"]

  boot_disk {
    initialize_params {
      image = var.windows_image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.office_external_lan.self_link
  }
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
    subnetwork = google_compute_subnetwork.office_external_lan.self_link
  }
}
