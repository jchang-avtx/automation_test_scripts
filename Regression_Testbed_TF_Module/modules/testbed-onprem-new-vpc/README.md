## Aviatrix - Terrform Modules - Onprem Setup

### Description
This Terraform modules sets up a onprem connection for simulation in the Regression Testbed environment. Creates an AWS VPC with Ubuntu instances, AWS VGW, AWS CGW, AWS VPN connection, Aviatrix GW, and Aviatrix Site2Cloud connection.

### Pre-requisites

* An Aviatrix controller
* An Aviatrix access account

### Usage:
To create an onprem connection:
```
module "onprem-connection" {
  source                 = "./modules/testbed-onprem-new-vpc"
  owner                  = "matthew"
  resource_name_label    = "testbed"
  gw_name                = "main-onprem-gw"
  s2c_connection_name    = "main-onprem-s2c"
  account_name           = "awsRegAccount"

  onprem_vpc_cidr        = "10.80.0.0/16"
  pub_subnet_cidr        = "10.80.0.0/24"
  pri_subnet_cidr        = "10.80.1.0/24"
  pub_subnet_az          = "us-west-2b" # optional
  pri_subnet_az          = "us-west-2c" # optional
  pub_hostnum            = "10"
  pri_hostnum            = "8"
  termination_protection = true
  public_key             = file("./public_key.pub")
  ubuntu_ami             = "ami-abcdefg123456" # optional

  remote_subnet_cidr     = ["28.10.1.0/24", "28.10.0.0/24", "10.28.1.0/24", "10.28.0.0/24"]
  local_subnet_cidr      = ["10.180.0.0/24"] # optional
  static_route_cidr      = ["10.180.0.0/24", "180.10.0.0/24"]
  asn                    = 64512
}
```

### Variables
- **owner**

Name of the owner for the AWS resources. Optional.

- **resource_name_label**

Resource name label for resources created in this module.

- **gw_name**

Name of Aviatrix onprem GW being created. Default is "onprem-gw".

- **s2c_connection_name**

Name of Aviatrix Site2Cloud connection being created. Default is "onprem-s2c".

- **account_name**

Access account name in Aviatrix controller.

- **onprem_vpc_cidr**

VPC cidr for onprem VPC.

- **pub_subnet_cidr**

Subnet cidr to launch Aviatrix GW and public ubuntu instance into.

- **pri_subnet_cidr**

Subnet cidr to launch private ubuntu instance into.

- **pub_subnet_az**
- **pri_subnet_az**

Subnet availability zone. Optional.

- **pub_hostnum**

Number to be used for public ubuntu instance private ip host part.

- **pri_hostnum**

Number to be used for private ubuntu instance private ip host part.

- **termination_protection**

Whether to turn on EC2 instance termination protection.

- **public_key**

Public key to ssh into ubuntu instances.

- **ubuntu_ami**

AMI of the ubuntu instances. Optional.

- **remote_subnet_cidr**

List of remote subnet cidrs for Site2Cloud connection.

- **local_subnet_cidr**

List of local subnet cidrs for Site2Cloud connections. Optional.

- **static_route_cidr**

List of static route cidrs for VPN connection.

- **asn**

ASN for the AWS VGW. Default is 64512.

### Outputs

- **onprem_vpc_info**

Displays the vpc name and id.
```
onprem_vpc_info = [
  "<<vpc name>>",
  "<<vpc id>>",
  "<<vpc cidr>>",
]
```

- **onprem_public_subnet_info**

Displays the public subnet name and cidr block.
```
onprem_public_subnet_info = [
  "<<subnet name>>",
  "<<subnet cidr>>"
]
```

- **onprem_private_subnet_info**

Displays the private subnet name and cidr block.
```
onprem_private_subnet_info = [
  "<<subnet name>>",
  "<<subnet cidr>>"
]
```

- **onprem_public_ubuntu_info**

Displays the public ubuntu name, id, public ip, and private ip.
```
onprem_public_ubuntu_info = [
  "<<instance name>>",
  "<<instance id>>",
  "<<instance public ip>>",
  "<<instance private ip>>",
]
```

- **onprem_private_ubuntu_info**

Displays the private ubuntu name, id, and private ip.
```
onprem_private_ubuntu_info = [
  "<<instance name>>",
  "<<instance id>>",
  "<<instance private ip>>",
]
```

- **onprem_aviatrix_gw_info**

Displays the aviatrix gateway name and cloud instance id.
```
onprem_aviatrix_gw_info = [
  "<<gw name>>",
  "<<gw instance id>>",
  "<<gw public subnet>>"
]
```

- **onprem_vgw_info**

Displays the aws vpn gateway name and id.
```
onprem_vgw_info = [
  "<<vgw name>>",
  "<<vgw id>>"
]
```

- **onprem_cgw_info**

Displays the aws customer gateway name and id.
```
onprem_cgw_info = [
  "<<cgw name>>",
  "<<cgw id>>"
]
```

- **onprem_vpn_info**

Displays the vpn connection name and id.
```
onprem_vpn_info = [
  "<<vpn name>>",
  "<<vpn id>>"
]
```

- **onprem_s2c_info**

Displays the aviatrix site2cloud connection name.
```
onprem_s2c_info = [
  "<<s2c connection name>>",
  "<<s2c remote subnet cidrs>>"
]
```
