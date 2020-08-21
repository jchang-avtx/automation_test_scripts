## Aviatrix - Terraform Modules - GCP Client Setup

### Description
This Terraform module creates an Ubuntu instance in a particular VPC located in a particular region. Ubuntu instance is also assigned with security group which allows incoming SSH and ICMP from all hosts.

### Usage:

```
module "gcp_client" {
  source      = "./gcp_client"
  region      = "<<enter_region>>"
  vpc_id      = "<<enter_vpc_id>>"
  ssh_user    = "<<enter_ssh_user>>"
  public_key  = "<<enter_public_key>>"
  subnet_name = "<<enter_subnet_name>>"
}
```

### Variables

- **region**

Name of region to launch Ubuntu client

- **vpc_id**

VPC ID to deploy resources

- **ssh_user**

SSH user to login to Ubuntu client

- **public_key**

Public key for creating Ubuntu client

- **subnet_name**

Name of subnet to launch Ubuntu client


### Outputs

- **ubuntu_public_ip**

Public IP of the Ubuntu instance

- **ubuntu_private_ip**

Private IP of the Ubuntu instance

- **ubuntu_instance_id**

Instance ID of the Ubuntu instance
