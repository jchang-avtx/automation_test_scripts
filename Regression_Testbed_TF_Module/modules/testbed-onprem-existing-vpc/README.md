## Aviatrix - Terrform Modules - Onprem Setup with Existing VPC

### Description
This Terraform modules sets up a onprem connection for simulation in the Regression Testbed environment. Creates an AWS VGW, AWS CGW, AWS VPN connection, Aviatrix GW, and Aviatrix Site2Cloud connection.

### Pre-requisites

* An existing VPC
* An Aviatrix controller
* An Aviatrix access account

### Usage:
To create an onprem connection:
```
module "onprem-connection" {
  source                 = "./modules/testbed-onprem-existing-vpc"
  resource_name_label    = "testbed"
  gw_name                = "main-onprem-gw" # optional
  s2c_connection_name    = "main-onprem-s2c" # optional
  account_name           = "awsRegAccount"
  onprem_vpc_id          = "vpc-abcedfg1234567"
  pub_subnet_cidr        = "10.180.0.0/28"
  remote_subnet_cidr     = ["28.10.1.0/24", "28.10.0.0/24", "10.28.1.0/24", "10.28.0.0/24"]
  local_subnet_cidr      = ["10.180.0.0/24"] # optional
  static_route_cidr      = ["10.180.0.0/24", "180.10.0.0/24"]
  asn                    = 64512
}
```

### Variables
- **resource_name_label**

Resource name label for resources created in this module.

- **gw_name**

Name of Aviatrix onprem GW being created. Default is "onprem-gw".

- **s2c_connection_name**

Name of Aviatrix Site2Cloud connection being created. Default is "onprem-s2c".

- **account_name**

Access account name in Aviatrix controller.

- **onprem_vpc_id**

VPC IP for onprem VPC to launch Aviatrix GW and S2C connection in.

- **pub_subnet_cidr**

Subnet cidr to launch Aviatrix GW into.

- **remote_subnet_cidr**

List of remote subnet cidrs for Site2Cloud connection.

- **local_subnet_cidr**

List of local subnet cidrs for Site2Cloud connections. Optional.

- **static_route_cidr**

List of static route cidrs for VPN connection.

- **asn**

ASN for the AWS VGW. Default is 64512.


### Outputs

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
  "<<remote_subnet_cidr>>"
]
```
