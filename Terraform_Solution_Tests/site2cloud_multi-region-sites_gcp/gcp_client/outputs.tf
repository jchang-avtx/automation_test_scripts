# Outputs for GCP Client module

output "ubuntu_public_ip" {
  value = google_compute_instance.client[*].network_interface.0.access_config.0.nat_ip
}

output "ubuntu_private_ip" {
  value = google_compute_instance.client[*].network_interface.0.network_ip
}

output "ubuntu_instance_id" {
  value = google_compute_instance.client[*].id
}
