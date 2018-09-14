Description
-----------
  Terraform configuration files to create Aviatrix gateways with single AZ Ha enabled.

Sample
------
aviatrix_gateway.aws_gateway:
  account_name = aws-fqdn-root
  cidr = 192.168.101.0/24
  cloud_type = 1
  gw_name = DNS-SingleAZ-GW
  vpc_id = vpc-0d288427933081d57
  vpc_net = 10.255.0.0/24
  vpc_reg = us-east-2
  vpc_size = t2.micro
  single_az_ha = enabled

Gateway Single AZ HA
--------------------
Single AZ HA Link [here](http://docs.aviatrix.com/HowTos/gateway.html#gateway-single-az-ha).

