# Outputs for AWS Client module

output "ubuntu_public_ip" {
  value = aws_instance.client[*].public_ip
}

output "ubuntu_private_ip" {
  value = aws_instance.client[*].private_ip
}

output "ubuntu_instance_id" {
  value = aws_instance.client[*].id
}

output "ubuntu_instance_state" {
  value = aws_instance.client[*].instance_state
}
