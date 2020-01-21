## aviatrix_firenet | aviatrix_firewall_instance

---

### Usage
```
  terraform init
  terraform apply -var-file=/path/provider_cred.tfvars -auto-approve
  terraform plan -var-file=/path/provider_cred.tfvars
  terraform show

  terraform state rm aviatrix_firewall_instance.firenet_instance
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_firewall_instance.firenet_instance `terraform output firewall_instance_id1`
  terraform plan -var-file=/path/provider_cred.tfvars
  terraform show

  terraform state rm aviatrix_firewall_instance.firenet_instance3
  terraform import -var-fiile=/path/provider_cred.tfvars aviatrix_firewall_instance.firenet_instance3 `terraform output firewall_instance_id3`
  terraform plan -var-file=/path/provider_cred.tfvars
  terraform show

  terraform state rm aviatrix_firenet.firenet
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_firenet.firenet `terraform output vpc_id1`
  terraform plan -var-file=/path/provider_cred.tfvars
  terraform show

  terraform state rm aviatrix_firenet.fqdn_firenet
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_firenet.fqdn_firenet `terraform output vpc_id2`
  terraform plan -var-file=/path/provider_cred.tfvars
  terraform show

  terraform destroy -var-file=/path/provider_cred.tfvars -auto-approve
```

### Module
- will be testing both Generic vendor and FQDN
- 2 FireNet VPCs
- 2 FireNet AWS TGWs
- 1 aws_tgw_vpc_attachment
  - for variance in vpc attachment option
- 2 FireNet Aviatrix transit gateways
  - 1 with HA
  - 1 without HA
- 1 FQDN gateway
- 3 FireNet firewall instances
  - 1 for primary
  - 1 for HA
  - 1 for FQDN
- 1 FireNet resource with 2 associations (primary and HA)
- 1 FireNet resource with 1 association (FQDN)
