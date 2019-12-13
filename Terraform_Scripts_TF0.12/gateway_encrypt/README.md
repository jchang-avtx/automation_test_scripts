## aviatrix_gateway (Encrypt EBS Volume)

### Prerequisite
* must create a ```policy.json``` to use to apply to the key policy

---

### Usage
```
  terraform init
  terraform apply -var-file=/path/provider_cred.tfvars -auto-approve # key enabled
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=disableKey.tfvars \
                  -auto-approve
  terraform show

  terraform destroy -var-file=/path/provider_cred.tfvars \
                  -target=aviatrix_vpc.transit_encrypt_vpc \
                  -target=aviatrix_vpc.spoke_encrypt_vpc \
                  -auto-approve
```
