# Aviatrix Transit FireNet (Azure)

---

### Infrastructure
- Azure FireNet VNet
- Azure transit gateway (Transit FireNet-enabled) (HA)
- Azure Spoke VNet
- Azure Spoke Native-Peering (attach to transit gateway)
- Azure firewall instance (launch in FireNet VNet, associated with FireNet)
- Azure FireNet

### Test case
- verify Azure Transit FireNet build
- verify Azure Native Spoke Peering resource


### Usage
```
  terraform init
  terraform apply -var-file=/path/provider_cred.tfvars -auto-approve
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_azure_spoke_native_peering.arm_transit_firenet_spoke_native_peer
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_azure_spoke_native_peering.arm_transit_firenet_spoke_native_peer transit_gateway_name~spoke_account_name~spoke_vpc_id
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform destroy -var-file=/path/provider_cred.tfvars -auto-approve
```
