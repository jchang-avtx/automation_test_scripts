## aviatrix_transit_gateway_peering

---

### Topology
- TGW
- TGW VPN conn
- 2 Transit gateways
- 1 of the transit gw attached to the TGW
- Transit gateway peering (exclude the VPN conn + CIDRs) (14894)

### Usage
```
  terraform init
  terraform apply -var-file=/path/provider_cred.tfvars -auto-approve
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_transit_gateway_peering.test_transit_gw_peering
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_transit_gateway_peering.test_transit_gw_peering transitGW1~transitGW2
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform destroy -var-file=/path/provider_cred.tfvars -auto-approve
```
