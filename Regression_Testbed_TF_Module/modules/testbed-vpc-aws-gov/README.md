## Aviatrix - Terraform Modules - AWS GOV VPC Setup

### Description
This Terraform module creates an AWS GOV VPC for the Regression Testbed environment. VPC includes: 2 public subnets, 1 private subnet, public rtb, private rtb, public ubuntu, private ubuntu. Ubuntu instances have an eip assigned to them and termination protection enabled. SSH and ICMP are open to 0.0.0.0/0. VPCs created in US-Gov-West and US-Gov-East.

### Usage:
To create a filled AWS GOV VPC:
```
module "aws-vpc-gov" {
  source          	  = "./modules/testbed-vpc-aws-gov"
  termination_protection      = <<true/false>>
  owner                       = "<<insert your name>>"
  resource_name_label         = "<<input label for all resources>>"

  # AWS Gov Account
  aws_gov_access_key = "<<your aws primary access key>>"
  aws_gov_secret_key = "<<your aws secret key>>"

  # AWS Gov VPC setup
  vpc_public_key              = "<<your public key to access ubuntu instances>>"
  pub_hostnum                 = <<input instance private ip hostnum>>
  pri_hostnum                 = <<input instance private ip hostnum>>

  # US Gov West 1
  vpc_count_gov_west             = <<input number of vpcs>>
  vpc_cidr_gov_west              = [<<insert cidrs>>]
  pub_subnet1_cidr_gov_west      = [<<insert cidrs>>]
  pub_subnet2_cidr_gov_west      = [<<insert cidrs>>]
  pri_subnet_cidr_gov_west       = [<<insert cidrs>>]
  pub_subnet1_az_gov_west        = [<<insert az's>>]
  pub_subnet2_az_gov_west        = [<<insert az's>>]
  pri_subnet_az_gov_west         = [<<insert az's>>]
  ubuntu_ami_gov_west            = "<<insert ami>>"

  # US Gov East 1
  vpc_count_gov_east             = <<input number of vpcs>>
  vpc_cidr_gov_east              = [<<insert cidrs>>]
  pub_subnet1_cidr_gov_east      = [<<insert cidrs>>]
  pub_subnet2_cidr_gov_east      = [<<insert cidrs>>]
  pri_subnet_cidr_gov_east       = [<<insert cidrs>>]
  pub_subnet1_az_gov_east        = [<<insert az's>>]
  pub_subnet2_az_gov_east        = [<<insert az's>>]
  pri_subnet_az_gov_east         = [<<insert az's>>]
  ubuntu_ami_gov_east            = "<<insert ami>>"
}
```

### Variables

- **aws_gov_access_key**

AWS Gov account's  access key.

- **aws_gov_secret_key**

AWS Gov account's  secret key.

- **termination_protection**

Whether to enable termination protection for ec2 instances.

- **owner**

Name of the owner for the AWS resources. Optional.

- **resource_name_label**

The label for the resource name.

- **vpc_public_key**

Public key used for creating key pair for all instances.

- **pub_hostnum**

Number to be used for public ubuntu instance private ip host part. Must be a whole number that can be represented as a binary integer.

- **pri_hostnum**

Number to be used for private ubuntu instance private ip host part. Must be a whole number that can be represented as a binary integer.

- **vpc_count_gov_west**
- **vpc_count_gov_east**

The number of vpcs to create in the given AWS region.

- **vpc_cidr_gov_west**
- **vpc_cidr_gov_east**

The cidr of a vpc for a given region. List of strings.

- **pub_subnet1_cidr_gov_west**
- **pub_subnet1_cidr_gov_east**

The cidr for public subnet 1 of a given region. List of strings.

- **pub_subnet2_cidr_gov_west**
- **pub_subnet2_cidr_gov_east**

The cidr for public subnet 2 of a given region. List of strings.

- **pri_subnet_cidr_gov_west**
- **pri_subnet_cidr_gov_east**

The cidr for a private subnet of a given region. List of strings.

- **pub_subnet1_az_gov_west**
- **pub_subnet1_az_gov_east**

The availability zone for public subnet 1 of a given region. List of strings.

- **pub_subnet2_az_gov_west**
- **pub_subnet2_az_gov_east**

The availability zone for public subnet 2 of a given region. List of strings.

- **pri_subnet_az_gov_west**
- **pri_subnet_az_gov_east**

The availability zone for a private subnet of a given region. List of strings.

- **ubuntu_ami_gov_west**
- **ubuntu_ami_gov_east**

AMI of the ubuntu instances.

### Outputs

- **gov_west_vpc_info**
- **gov_east_vpc_info**

Outputs the vpc info (ID and name) for all vpc's in the given regions.

- **gov_west_subnet_info**
- **gov_east_subnet_info**

Outputs the subnet info (name and cidr) for all subnets in the given regions.

- **gov_west_ubuntu_info**
- **gov_east_ubuntu_info**

Outputs the ubuntu info (name, id, public ip, and private ip) for all instances in the given regions.
