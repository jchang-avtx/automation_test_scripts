## aviatrix_gateway
---
Testing ARM gateway full functionality

**Note**
* if testing HA, do not enable NAT (*enable_nat*), nor (*vpn_access*)
  * GCP restriction: Can only have one SNAT gw per VPC network
  * Aviatrix restriction: Peering HA is not supported on VPN gw (in general)
