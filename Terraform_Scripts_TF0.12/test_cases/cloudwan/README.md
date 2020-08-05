# Aviatrix CloudWAN

## Prerequisites
- 1 subnets
- 1 ENI (1 per subnet)
- 1 EIP per ENI
- AWS EC2 instance with CSR (BYOL) AMI

## Module 1 (Transit)
- 1 Aviatrix transit VPC
- Aviatrix transit gateway

## Module 2 (TGW)
- 1 Aviatrix AWS TGW

## Module 3 (Azure Virtual WAN)
- Azure Virtual WAN
- Azure Hub
- Azure VPN gateway
EDIT: Must be created beforehand due to 30 min wait time for status up
Source: https://docs.aviatrix.com/HowTos/cloud_wan_workflow_azure_vwan.html

## Common
- CSR Branch router
- branch interface config
- branch to cloud attachment
- branch tag (handles attach to branch and commit)

## To be built
- AWS Global Network module

---
Verified on both 6.0-patch and 6.1
**Note:** R2.16 should only be used with 6.1+
