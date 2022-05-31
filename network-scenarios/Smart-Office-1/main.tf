provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network_peering" "peer_external_to_internal" {
  name         = "peer-external-to-internal"
  network      = google_compute_network.office_external_network.self_link
  peer_network = google_compute_network.office_internal_network.self_link
}

resource "google_compute_network_peering" "peer_internal_to_external" {
  name         = "peer-internal-to-external"
  network      = google_compute_network.office_internal_network.self_link
  peer_network = google_compute_network.office_external_network.self_link
}

resource "google_compute_network_peering" "peer_internal_office_to_server" {
  name         = "peer-internal-office-to-server"
  network      = google_compute_network.office_internal_network.self_link
  peer_network = google_compute_network.internal_server_network.self_link
}

resource "google_compute_network_peering" "peer_internal_server_to_office" {
  name         = "peer-internal-server-to-office"
  network      = google_compute_network.internal_server_network.self_link
  peer_network = google_compute_network.office_internal_network.self_link
}

resource "google_compute_firewall" "allow_ssh_internal" {
  name      = "allow-ssh-internal"
  network   = google_compute_network.office_internal_network.self_link
  project   = var.project_id
  priority  = 65534
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}

resource "google_compute_firewall" "allow_ssh_external" {
  name      = "allow-ssh-external"
  network   = google_compute_network.office_external_network.self_link
  project   = var.project_id
  priority  = 65534
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}

resource "google_compute_firewall" "allow_ssh_server" {
  name      = "allow-ssh-server"
  network   = google_compute_network.internal_server_network.self_link
  project   = var.project_id
  priority  = 65534
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}


resource "google_compute_firewall" "allow_internal" {
  name      = "allow-internal"
  network   = google_compute_network.office_internal_network.self_link
  project   = var.project_id
  priority  = 65534
  direction = "INGRESS"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = [google_compute_subnetwork.employees_lan.ip_cidr_range, google_compute_subnetwork.printer_lan.ip_cidr_range]
}


resource "google_compute_firewall" "allow_external" {
  name      = "allow-external"
  network   = google_compute_network.office_external_network.self_link
  project   = var.project_id
  priority  = 65534
  direction = "INGRESS"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = [google_compute_subnetwork.office_external_lan.ip_cidr_range]
}

resource "google_compute_firewall" "allow_external_from_internal" {
  name      = "allow-external-from-internal"
  network   = google_compute_network.office_external_network.self_link
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

  source_ranges = [google_compute_subnetwork.printer_lan.ip_cidr_range, google_compute_subnetwork.employees_lan.ip_cidr_range]
  target_tags   = ["employee"]
}

resource "google_compute_firewall" "allow_internal_from_external" {
  name      = "allow-internal-from-external"
  network   = google_compute_network.office_internal_network.self_link
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

  source_ranges = [google_compute_instance.employee_remote_pc.network_interface[0].network_ip]
  target_tags   = ["employee", "printer"]
}

resource "google_compute_firewall" "allow_printer_from_server" {
  name      = "allow-printer-from-server"
  network   = google_compute_network.office_internal_network.self_link
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

  source_ranges = [google_compute_subnetwork.printer_server_lan.ip_cidr_range]
  target_tags   = ["printer"]
}

resource "google_compute_firewall" "allow_server_from_printer" {
  name      = "allow-server-from-printer"
  network   = google_compute_network.internal_server_network.self_link
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

  source_ranges = [google_compute_subnetwork.printer_lan.ip_cidr_range]
  target_tags   = ["server"]
}
