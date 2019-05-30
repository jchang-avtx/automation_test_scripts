## aviatrix_gateway
---
Testing GCP gateway full functionality

**Note**
* if testing HA, do not enable NAT (*enable_nat*), nor (*vpn_access*)
  * GCP restriction: Can only have one SNAT gw per VPC network
  * Aviatrix restriction: Peering HA is not supported on VPN gw (in general)
* only testing updating GCP GW with HA parameters (creating a HA gw in a separate step)
