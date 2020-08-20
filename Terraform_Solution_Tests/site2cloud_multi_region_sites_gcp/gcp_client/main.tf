resource "google_compute_firewall" "allow-ssh-and-icmp" {
  name          = "s2c-firewall-${substr(uuid(),0,6)}"
  network       = var.vpc_id
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "icmp"
  }

  allow {
    #SSH
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["s2c-ubuntu"]
}

data "google_compute_zones" "region" {
  region  = var.region
}

resource "google_compute_instance" "client" {
  name         = "s2c-ubuntu-client-${var.region}-${substr(uuid(),0,6)}"
  machine_type = "f1-micro"
  zone         = data.google_compute_zones.region.names[0]

  boot_disk {
    initialize_params {
      image = "ubuntu-1804-lts"
    }
  }

  network_interface {
    network    = var.vpc_id
    subnetwork = var.subnet_name

    access_config {
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.public_key)}"
  }

  tags = ["s2c-ubuntu"]
}
