provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_firewall" "allow_web" {
  name      = "allow-web"
  network   = google_compute_network.scada_network.self_link
  project   = var.project_id
  priority  = 65534
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]
}

resource "google_compute_firewall" "allow_mail" {
  name      = "allow-mail"
  network   = google_compute_network.scada_network.self_link
  project   = var.project_id
  priority  = 65534
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["25", "465", "587"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["mail-server"]
}

resource "google_compute_firewall" "allow_enterprise" {
  name      = "allow-enterprise"
  network   = google_compute_network.scada_network.self_link
  project   = var.project_id
  priority  = 65534
  direction = "INGRESS"

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

  source_ranges = [google_compute_subnetwork.enterprise_lan.ip_cidr_range, google_compute_subnetwork.internet_dmz.ip_cidr_range, google_compute_subnetwork.operation_dmz.ip_cidr_range]
  target_tags   = ["enterprise"]
}

resource "google_compute_firewall" "allow_operation" {
  name      = "allow-operation"
  network   = google_compute_network.scada_network.self_link
  project   = var.project_id
  priority  = 65534
  direction = "INGRESS"

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

  source_ranges = [google_compute_subnetwork.operation_dmz.ip_cidr_range, google_compute_subnetwork.enterprise_lan.ip_cidr_range, google_compute_subnetwork.internet_dmz.ip_cidr_range]
  target_tags   = ["operation"]
}

resource "google_compute_firewall" "allow_ops_from_hmi" {
  name      = "allow-ops-from-hmi"
  network   = google_compute_network.scada_network.self_link
  project   = var.project_id
  priority  = 65534
  direction = "INGRESS"

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

  source_tags = ["hmi-pro", "hmi-pre"]
  target_tags = ["operation"]
}

resource "google_compute_firewall" "allow_hmi_pro_from_ops" {
  name      = "allow-hmi-pro-from-ops"
  network   = google_compute_network.scada_network.self_link
  project   = var.project_id
  priority  = 65534
  direction = "INGRESS"

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

  source_tags = ["operation"]
  target_tags = ["hmi-pro"]
}

resource "google_compute_firewall" "allow_hmi_pre_from_ops" {
  name      = "allow-hmi-pre-from-ops"
  network   = google_compute_network.scada_network.self_link
  project   = var.project_id
  priority  = 65534
  direction = "INGRESS"

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

  source_tags = ["operation"]
  target_tags = ["hmi-pre"]
}

resource "google_compute_firewall" "allow_hmi_from_server_pro" {
  name      = "allow-hmi-from-server-pro"
  network   = google_compute_network.scada_network.self_link
  project   = var.project_id
  priority  = 65534
  direction = "INGRESS"

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

  source_tags = ["scada-pro"]
  target_tags = ["hmi-pro"]
}

resource "google_compute_firewall" "allow_hmi_from_server_pre" {
  name      = "allow-hmi-from-server-pre"
  network   = google_compute_network.scada_network.self_link
  project   = var.project_id
  priority  = 65534
  direction = "INGRESS"

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

  source_tags = ["scada-pre"]
  target_tags = ["hmi-pre"]
}

resource "google_compute_firewall" "allow_server_from_hmi_pro" {
  name      = "allow-server-from-hmi-pro"
  network   = google_compute_network.scada_network.self_link
  project   = var.project_id
  priority  = 65534
  direction = "INGRESS"

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

  source_tags = ["hmi-pro"]
  target_tags = ["scada-pro"]
}

resource "google_compute_firewall" "allow_server_from_hmi_pre" {
  name      = "allow-server-from-hmi-pre"
  network   = google_compute_network.scada_network.self_link
  project   = var.project_id
  priority  = 65534
  direction = "INGRESS"

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

  source_tags = ["hmi-pre"]
  target_tags = ["scada-pre"]
}

resource "google_compute_firewall" "allow_bus_pro" {
  name      = "allow-bus-pro"
  network   = google_compute_network.scada_network.self_link
  project   = var.project_id
  priority  = 65534
  direction = "INGRESS"

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

  source_tags = ["scada-pro", "plc-pro", "rtu-pro"]
  target_tags = ["scada-pro", "plc-pro", "rtu-pro"]
}

resource "google_compute_firewall" "allow_bus_pre" {
  name      = "allow-bus-pre"
  network   = google_compute_network.scada_network.self_link
  project   = var.project_id
  priority  = 65534
  direction = "INGRESS"

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

  source_tags = ["scada-pre", "plc-pre", "rtu-pre"]
  target_tags = ["scada-pre", "plc-pre", "rtu-pre"]
}
