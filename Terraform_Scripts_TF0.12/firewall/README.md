## aviatrix_firewall

---

### Usage
```
  terraform init
  terraform apply -var-file=/path/provider_cred.tfvars -auto-approve
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_firewall.test_firewall
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_firewall.test_firewall firewallGW
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode

  terraform state rm aviatrix_firewall.test_firewall_icmp
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_firewall.test_firewall_icmp firewallGW2
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=icmpEmpty.tfvars \
                  -auto-approve
  terraform plan -var-file=/path/provider_cred.tfvars \
                 -var-file=icmpEmpty.tfvars
                 -detailed-exitcode

  terraform destroy -var-file=/path/provider_cred.tfvars -auto-approve
```
