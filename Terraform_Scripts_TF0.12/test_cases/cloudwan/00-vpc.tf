resource random_integer csr_vpc_int {
  count = 2
  min = 1
  max = 126
}

resource aws_vpc csr_vpc {
  cidr_block = join(".", [random_integer.csr_vpc_int[0].result, random_integer.csr_vpc_int[1].result, "0.0/16"])

  tags = {
    Name = "csr-vpc"
    Purpose = "Terraform Regression"
  }
}

resource aws_subnet csr_vpc_subnet_1 {
  vpc_id = aws_vpc.csr_vpc.id
  cidr_block = join(".", [random_integer.csr_vpc_int[0].result, random_integer.csr_vpc_int[1].result, "10.0/24"])
  availability_zone = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "csr-vpc-subnet-1"
    Purpose = "Terraform Regression"
  }
}

# HA support for CloudWAN removed in 6.1
# resource aws_subnet csr_vpc_subnet_2 {
#   vpc_id = aws_vpc.csr_vpc.id
#   cidr_block = join(".", [random_integer.csr_vpc_int[0].result, random_integer.csr_vpc_int[1].result, "11.0/24"])
#   availability_zone = "us-east-2a"
#   map_public_ip_on_launch = true
#
#   tags = {
#     Name = "csr-vpc-subnet-2"
#     Purpose = "Terraform Regression"
#   }
# }

resource aws_network_interface csr_aws_netw_interface_1 {
  subnet_id = aws_subnet.csr_vpc_subnet_1.id
  security_groups = [aws_security_group.csr_sec_group.id]

  tags = {
    Name = "csr-aws-netw-interface-1"
    Purpose = "Terraform Regression"
  }
}

# HA support for CloudWAN removed in 6.1
# resource aws_network_interface csr_aws_netw_interface_2 {
#   subnet_id = aws_subnet.csr_vpc_subnet_2.id
#   security_groups = [aws_security_group.csr_sec_group.id]
#
#   tags = {
#     Name = "csr-aws-netw-interface-2"
#     Purpose = "Terraform Regression"
#   }
# }

resource aws_eip csr_eip_1 {
  tags = {
    Name = "csr-eip-1"
    Purpose = "Terraform Regression"
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

# HA support for CloudWAN removed in 6.1
# resource aws_eip csr_eip_2 {
#   tags = {
#     Name = "csr-eip-2"
#     Purpose = "Terraform Regression"
#   }
#
#   lifecycle {
#     ignore_changes = [tags]
#   }
# }

resource aws_eip_association csr_eip_association_1 {
  allocation_id = aws_eip.csr_eip_1.id
  network_interface_id = aws_network_interface.csr_aws_netw_interface_1.id
}

# HA support for CloudWAN removed in 6.1
# resource aws_eip_association csr_eip_association_2 {
#   allocation_id = aws_eip.csr_eip_2.id
#   network_interface_id = aws_network_interface.csr_aws_netw_interface_2.id
# }
