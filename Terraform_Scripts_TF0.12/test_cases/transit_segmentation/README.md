# Aviatrix MultiCloud Transit Segmentation

Supported in 6.2 - R2.17+

## Infrastructure
### OnPrem
- 1 VPC, 1 GW
- 1 VGW attached to VPC
- Private route table, propagating to VGW
- VGW conn to transit gateway

### Transit Network
- 1 VPC, 1 transit gw (AWS)
  - 1 VNet, 1 transit gw (Azure)
  - 1 VPC, 1 transit gw (GCP)
- 2 Segmentation security domains (Blue, Green)
- 1 Segmentation connection policy (join the 2 domains)
- 2 VPC, 2 spoke gw (AWS)
  - 1 VPC, 1 spoke gw (Azure)
  - 1 spoke gw (GCP) (utilise existing GCP VPC)
- 2 Segmentation security domain association (1 per spoke) (AWS)
  - 1x for Azure spoke to Blue
  - 1x for GCP spoke to Green

## Test cases
- verify Transit Segmentation in AWS
- verify Transit Segmentation between AWS and Azure Transit
- verify Transit Segmentation between AWS and GCP Transit
