# Aviatrix Transit FireNet (AWS)

---

### Infrastructure
- AWS FireNet VPC
- AWS transit gateway (Transit FireNet-enabled, Hybrid, connected_transit, ActiveMesh-enabled)
- AWS Spoke VPC (2)
- AWS spoke gateway (attach to transit gateway) (per spoke VPC)
- Site2Cloud (tunnel between spoke1 and transit)
- AWS firewall instance (launch in FireNet VPC, associated with FireNet)
- AWS FireNet
- Transit FireNet policy (2) (inspect both Spokes)
- Firewall Management Access (Site2Cloud's access-enabled)

### Test case
- verify AWS Transit FireNet build
- verify AWS Transit FireNet policies
- verify AWS Transit FireNet Firewall Management Access resource


### Usage
```
  terraform init
  terraform apply -var-file=/path/provider_cred.tfvars -auto-approve
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_transit_firenet_policy.transit_firenet_policy_1
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_transit_firenet_policy.transit_firenet_policy_1 transit_firenet_gateway_name~inspected_resource_name1
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_transit_firenet_policy.transit_firenet_policy_2
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_transit_firenet_policy.transit_firenet_policy_2 transit_firenet_gateway_name~inspected_resource_name2
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_firewall_management_access.transit_firenet_firewall_management_1
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_firewall_management_access.transit_firenet_firewall_management_1 transit_firenet_gateway_name
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform destroy -var-file=/path/provider_cred.tfvars -auto-approve
```
