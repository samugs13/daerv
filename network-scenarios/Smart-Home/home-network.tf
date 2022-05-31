resource "google_compute_network" "smart_home" {
  project                 = var.project_id
  name                    = "smart-home"
  mtu                     = 1460
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "home_lan" {
  name          = "home-lan"
  ip_cidr_range = var.private_subnet_cidr_blocks[0]
  region        = var.region
  network       = google_compute_network.smart_home.self_link
}

resource "google_compute_instance" "wireless_ap" {
  name           = "wireless-ap"
  machine_type   = var.machine_type
  project        = var.project_id
  zone           = var.zone
  can_ip_forward = true
  tags           = ["ssh"]

  boot_disk {
    initialize_params {
      image = var.debian_image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.home_lan.self_link
    access_config {}
  }

  metadata_startup_script = templatefile(var.proxy_config_path, { sources = google_compute_subnetwork.home_lan.ip_cidr_range })
}

resource "google_compute_instance" "smartphone" {
  name         = "smartphone"
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
    subnetwork = google_compute_subnetwork.home_lan.self_link
  }

  #metadata_startup_script = templatefile(var.proxy_provisioning_path, { proxy = google_compute_instance.wireless_ap.network_interface[0].network_ip, args = "", image = "nginx", tag = "" })
}

resource "google_compute_instance" "tablet" {
  name         = "tablet"
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
    subnetwork = google_compute_subnetwork.home_lan.self_link
  }

  #metadata_startup_script = templatefile(var.proxy_provisioning_path, { proxy = google_compute_instance.wireless_ap.network_interface[0].network_ip, args = "", image = "nginx", tag = "" })
}

resource "google_compute_instance" "ccu2" {
  name         = "ccu2"
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
    subnetwork = google_compute_subnetwork.home_lan.self_link
  }

  #metadata_startup_script = templatefile(var.proxy_provisioning_path, { proxy = google_compute_instance.wireless_ap.network_interface[0].network_ip, args = "", image = "nginx", tag = "" })
}

resource "google_compute_instance" "smart_bulb" {
  name         = "smart-bulb"
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
    subnetwork = google_compute_subnetwork.home_lan.self_link
  }

  metadata_startup_script = templatefile(var.proxy_provisioning_path, { proxy = google_compute_instance.wireless_ap.network_interface[0].network_ip, args = "", image = "nginx", tag = "" })
}

resource "google_compute_instance" "ip_camera" {
  name         = "ip-camera"
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
    subnetwork = google_compute_subnetwork.home_lan.self_link
  }

  #metadata_startup_script = templatefile(var.proxy_provisioning_path, { proxy = google_compute_instance.wireless_ap.network_interface[0].network_ip, args = "", image = "nginx", tag = "" })
}
