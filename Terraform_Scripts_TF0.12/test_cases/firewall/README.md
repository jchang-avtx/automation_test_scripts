## aviatrix_firewall

---

### Infrastructure
- pre-existing VPC
- 3 gateways to be built within different subnets
- firewall1
- firewall2 testing ICMP test cases
- firewall3 for stress testing rules (100 rules)

### Test Cases
- create, refresh, import, update, destroy firewall
- firewall data source
- verify update to handle empty port input with ICMP protocol
- verify 100 rule firewall without any issues (stress test)
- import case for separate firewall policy resource


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
