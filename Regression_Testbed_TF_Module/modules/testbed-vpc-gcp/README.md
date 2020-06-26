## Regression Testbed Terraform

### Description

This Terraform configuration creates an GCP test environment. Includes VPC, subnet, firewall, public instance, private instance.

### Prerequisites

- Google Cloud Project created
- existing SSH Key

### Usage
```
module "testbed-gcp" {
  source = "<<path to module>>"

  vpc_count             = 1
  resource_name_label   = "regression"
  pub_subnet            = ["10.20.0.0/24"]
  pri_subnet            = ["10.30.0.0/24"]
  pub_instance_zone     = ["us-central1-a"]
  pri_instance_zone     = ["us-central1-b"]
  pub_subnet_region     = "us-central1"
  pri_subnet_region     = "us-central1"
  pub_hostnum           = 20
  pri_hostnum           = 40
  ssh_user              = "regression"
  public_key            = file("~/.ssh/id_rsa.pub")
}
```

### Variables
- **vpc_count**

Number of VPCs to create.

- **resource_name_label**

Label name for all the resources.

- **pub_subnet**

List of public subnets.

- **pri_subnet**

List of private subnets.

- **pub_instance_zone**

List of GCP zones to launch public instance.

- **pri_instance_zone**

List of GCP zones to launch private instance.

- **pub_subnet_region**

Region of public subnet.

- **pri_subnet_region**

Region of private subnet.

- **pub_hostnum**

Public hostpart of the public Ubuntu instance.

- **pri_hostnum**

Private hostnum of the private Ubuntu instance.

- **ubuntu_image**

Name of GCP Image to use for VMs. Default is "ubuntu-1804-lts".

- **ssh_user**

SSH User for ssh into ubuntu instances.

- **public_key**

Public key to ssh into Ubuntu instances.

### Outputs

- **vpc_id**

VPC URI.

- **vpc_name**

VPC Name.

- **subnet_name**

Names of the subnets in the VPC.

- **subnet_cidr**

Cidr of the subnets in the VPC.

- **ubuntu_name**

Name of the Ubuntu instances.

- **ubuntu_public_ip**

Public IP of the public Ubuntu instance.

- **ubuntu_private_ip**

Private IP of the Ubuntu instances.

- **ubuntu_id**

Instance URI of the Ubuntu instances.
