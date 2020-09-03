# Dual Transit FireNet

## Infrastructure
### OnPrem
- 1 VPC , 1 GW (simulate on prem)
- AWS VGW (attach to VPC)
- Method 1
  - AWS VPN site2site connection to that on-prem GW - ASN must be same, IP = GW's IP
  - 1 Site2Cloud
- Method 2
  - private route table, propagate to VGW, VGW conn to transit

### FireNet
- 1 VPC firenet enabled , transit gw 1, enable transit firenet, connected transit enabled
- 1 VPC firenet enabled, transit gw 2, transit firenet, and egress enabled,
- 1 Firenet instance to be launched in the transit gw 1 vpc
- 1 Firenet instance to be launched in the transit gw 2 vpc
- 2 transit firenet policies for the spokes (on left side)

### Spokes
- 1 VPC, spoke gw, connected to transit gw 1
- 1 VPC, spoke gw 2, connected to transit gw 1 and 2

---
- **NOTE:** VMs (ubuntu) must be launched in private subnets
- **Source:** [Link](https://docs.aviatrix.com/_images/dual_transit.png)
