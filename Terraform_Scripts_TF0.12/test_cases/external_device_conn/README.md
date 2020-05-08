# Aviatrix Transit External Device Connection

---

### Infrastructure
- AWS transit VPC
- AWS transit gateway (HA enabled)
- AWS VPC
- AWS gateway (simulate on-prem router in above VPC)
- AWS spoke VPC
- AWS spoke gateway (HA enabled, attach to transit gateway)
- External device connection between transit and 'on-prem router'

### Test case
- verify AWS Transit Network build
- verify External device connection


### Usage
```
  terraform init
  terraform apply -var-file=/path/provider_cred.tfvars -auto-approve
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_transit_external_device_conn.ext_conn
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_transit_external_device_conn.ext_conn id
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=updateStatic.tfvars \
                  -auto-approve
  terraform show

  terraform destroy -var-file=/path/provider_cred.tfvars -auto-approve
```
