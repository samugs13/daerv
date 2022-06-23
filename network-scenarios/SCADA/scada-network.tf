resource "google_compute_network" "scada_network" {
  project                 = var.project_id
  name                    = "scada-network"
  mtu                     = 1460
  auto_create_subnetworks = false
}

resource "google_compute_router" "scada_router" {
  name    = "scada-router"
  network = google_compute_network.scada_network.self_link
  project = var.project_id

  bgp {
    asn               = 64512
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}

resource "google_compute_router_nat" "scada_nat" {
  name                               = "scada-nat"
  router                             = google_compute_router.scada_router.name
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_subnetwork" "internet_dmz" {
  name          = "internet-dmz"
  ip_cidr_range = var.private_subnet_cidr_blocks[0]
  region        = var.region
  network       = google_compute_network.scada_network.self_link
}

resource "google_compute_subnetwork" "enterprise_lan" {
  name          = "enterprise-lan"
  ip_cidr_range = var.private_subnet_cidr_blocks[1]
  region        = var.region
  network       = google_compute_network.scada_network.self_link
}

resource "google_compute_subnetwork" "operation_dmz" {
  name          = "operation-dmz"
  ip_cidr_range = var.private_subnet_cidr_blocks[2]
  region        = var.region
  network       = google_compute_network.scada_network.self_link
}

resource "google_compute_subnetwork" "ot_lan" {
  name          = "ot-lan"
  ip_cidr_range = var.private_subnet_cidr_blocks[3]
  region        = var.region
  network       = google_compute_network.scada_network.self_link
}

resource "google_compute_instance" "web_server" {
  name         = "web-server"
  machine_type = var.machine_type
  project      = var.project_id
  zone         = var.zone
  tags         = ["web-server"]

  boot_disk {
    initialize_params {
      image = var.debian_image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.internet_dmz.self_link
    access_config {}
  }

  metadata_startup_script = templatefile(var.docker_provisioning_path, { args = "-p 80:80", image = "nginx", tag = "latest" })
}

resource "google_compute_instance" "mail_server" {
  name         = "mail-server"
  machine_type = var.machine_type
  project      = var.project_id
  zone         = var.zone
  tags         = ["mail-server"]

  boot_disk {
    initialize_params {
      image = var.debian_image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.internet_dmz.self_link
    access_config {}
  }

  metadata_startup_script = templatefile(var.docker_provisioning_path, { args = "-p 25:25 -p 465:465 -p 587:587", image = "apache/james", tag = "latest" })
}

resource "google_compute_instance" "auth_server" {
  name         = "auth-server"
  machine_type = var.machine_type
  project      = var.project_id
  zone         = var.zone
  tags         = ["enterprise"]

  boot_disk {
    initialize_params {
      image = var.debian_image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.enterprise_lan.self_link
  }
}

resource "google_compute_instance" "business_server" {
  name         = "business-server"
  machine_type = var.machine_type
  project      = var.project_id
  zone         = var.zone
  tags         = ["enterprise"]

  boot_disk {
    initialize_params {
      image = var.debian_image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.enterprise_lan.self_link
  }
}

resource "google_compute_instance" "enterprise_desktop" {
  name         = "enterprise-desktop"
  machine_type = var.machine_type
  project      = var.project_id
  zone         = var.zone
  tags         = ["enterprise"]

  boot_disk {
    initialize_params {
      image = var.ubuntu_image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.enterprise_lan.self_link
  }
}

resource "google_compute_instance" "app_server" {
  name         = "app-server"
  machine_type = var.machine_type
  project      = var.project_id
  zone         = var.zone
  tags         = ["operation"]

  boot_disk {
    initialize_params {
      image = var.debian_image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.operation_dmz.self_link
  }
}

resource "google_compute_instance" "engineering_station" {
  name         = "engineering-station"
  machine_type = var.machine_type
  project      = var.project_id
  zone         = var.zone
  tags         = ["operation"]

  boot_disk {
    initialize_params {
      image = var.debian_image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.operation_dmz.self_link
  }
}

resource "google_compute_instance" "historian" {
  name         = "historian"
  machine_type = var.machine_type
  project      = var.project_id
  zone         = var.zone
  tags         = ["operation"]

  boot_disk {
    initialize_params {
      image = var.debian_image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.operation_dmz.self_link
  }
}

resource "google_compute_instance" "scada_server" {
  name         = "scada-server"
  machine_type = var.machine_type
  project      = var.project_id
  zone         = var.zone
  tags         = ["operation"]

  boot_disk {
    initialize_params {
      image = var.debian_image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.operation_dmz.self_link
  }
}

resource "google_compute_instance" "domain_controller" {
  name         = "domain-controller"
  machine_type = var.machine_type
  project      = var.project_id
  zone         = var.zone
  tags         = ["operation"]

  boot_disk {
    initialize_params {
      image = var.debian_image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.operation_dmz.self_link
  }
}

resource "google_compute_instance" "local_hmi_pro" {
  name         = "local-hmi-pro"
  machine_type = var.machine_type
  project      = var.project_id
  zone         = var.zone
  tags         = ["hmi-pro"]

  boot_disk {
    initialize_params {
      image = var.debian_image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.ot_lan.self_link
  }
}

resource "google_compute_instance" "local_hmi_pre" {
  name         = "local-hmi-pre"
  machine_type = var.machine_type
  project      = var.project_id
  zone         = var.zone
  tags         = ["hmi-pre"]

  boot_disk {
    initialize_params {
      image = var.debian_image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.ot_lan.self_link
  }
}

resource "google_compute_instance" "scada_server_pro" {
  name         = "scada-server-pro"
  machine_type = var.machine_type
  project      = var.project_id
  zone         = var.zone
  tags         = ["scada-pro"]

  boot_disk {
    initialize_params {
      image = var.debian_image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.ot_lan.self_link
  }
}

resource "google_compute_instance" "scada_server_pre" {
  name         = "scada-server-pre"
  machine_type = var.machine_type
  project      = var.project_id
  zone         = var.zone
  tags         = ["scada-pre"]

  boot_disk {
    initialize_params {
      image = var.debian_image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.ot_lan.self_link
  }
}

resource "google_compute_instance" "plc_pro" {
  name         = "plc-pro"
  machine_type = var.machine_type
  project      = var.project_id
  zone         = var.zone
  tags         = ["plc-pro"]

  boot_disk {
    initialize_params {
      image = var.debian_image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.ot_lan.self_link
  }
}

resource "google_compute_instance" "rtu_pro" {
  name         = "rtu-pro"
  machine_type = var.machine_type
  project      = var.project_id
  zone         = var.zone
  tags         = ["rtu-pro"]

  boot_disk {
    initialize_params {
      image = var.debian_image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.ot_lan.self_link
  }
}

resource "google_compute_instance" "plc_pre" {
  name         = "plc-pre"
  machine_type = var.machine_type
  project      = var.project_id
  zone         = var.zone
  tags         = ["plc-pre"]

  boot_disk {
    initialize_params {
      image = var.debian_image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.ot_lan.self_link
  }
}

resource "google_compute_instance" "rtu_pre" {
  name         = "rtu-pre"
  machine_type = var.machine_type
  project      = var.project_id
  zone         = var.zone
  tags         = ["rtu-pre"]

  boot_disk {
    initialize_params {
      image = var.debian_image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.ot_lan.self_link
  }
}
