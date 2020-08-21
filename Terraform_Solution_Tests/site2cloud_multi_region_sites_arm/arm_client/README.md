## Aviatrix - Terraform Modules - ARM Client Setup

### Description
This Terraform module creates an Ubuntu instance in a particular VNet located in a particular region. Ubuntu instance is also assigned with security group which allows incoming SSH and ICMP from all hosts.

### Usage:

```
module "arm_client" {
  source     = "./arm_client"
  region     = "<<enter_region>>"
  vpc_id     = "<<enter_vpc_id>>"
  public_key = "<<enter_public_key>>"
  subnet_id  = "<<enter_subnet_id>>"
}
```

### Variables

- **region**

Name of region to launch Ubuntu client

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
