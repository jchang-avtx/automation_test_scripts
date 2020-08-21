## Aviatrix - Terraform Modules - AWS Client Setup

### Description
This Terraform module creates an Ubuntu instance in a particular VPC located in a particular region. Ubuntu instance is also assigned with security group which allows incoming SSH and ICMP from all hosts.

### Usage:

```
module "aws_client" {
  source     = "./aws_client"
  region     = "<<enter_region>>"
  access_key = "<<enter_aws_access_key>>"
  secret_key = "<<enter_aws_secret_key>>"
  deploy     = <<true/false>>
  vpc_id     = "<<enter_vpc_id>>"
  public_key = "<<enter_public_key>>"
  subnet_id  = "<<enter_subnet_id>>"
}
```

### Variables

- **region**

Name of region to launch Ubuntu client

- **access_key**

AWS access key

- **secret_key**

AWS secret key

- **deploy**

Whether to deploy resource in this region or not

- **vpc_id**

VPC ID to deploy resources

- **public_key**

Public key for creating Ubuntu client

- **subnet_id**

Subnet ID to launch Ubuntu client


### Outputs

- **ubuntu_public_ip**

Public IP of the Ubuntu instance

- **ubuntu_private_ip**

Private IP of the Ubuntu instance

- **ubuntu_instance_id**

Instance ID of the Ubuntu instance

- **ubuntu_instance_state**

Instance state of the Ubuntu instance
