data aws_ami csr_ami {
  most_recent = true
  owners = ["aws-marketplace"] # Canonical
  filter {
    name   = "product-code"
    values = ["5tiyrfb5tasxk9gmnab39b843"] # aws ec2 describe-images --region us-east-2 --filters "Name=product-code,Values=5tiyrfb5tasxk9gmnab39b843"
  }
}

resource aws_instance csr_instance_1 {
  # ami = "ami-01f002df082c33e90"
  ami = data.aws_ami.csr_ami.id
  disable_api_termination = false
  instance_type = "t2.medium"
  key_name = var.csr_instance_key
  # subnet_id = aws_subnet.csr_vpc_subnet_1.id # already specified in ENI

  network_interface {
    network_interface_id = aws_network_interface.csr_aws_netw_interface_1.id
    device_index = 0
  }
  # network_interface {
  #   network_interface_id = aws_network_interface.csr_aws_netw_interface_2.id
  #   device_index = 1
  # }

  tags = {
    Name = "csr-instance-1"
    Purpose = "Terraform Regression"
  }
}
