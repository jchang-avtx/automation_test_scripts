## aviatrix_transit_gateway (gcp)

---

### Usage
```
  terraform init
  terraform apply -var-file=/path/provider_cred.tfvars -auto-approve
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_transit_gateway.gcp_transit_gateway
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_transit_gateway.gcp_transit_gateway gcloudtransitgw
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=enableSingleAZHA.tfvars \
                  -auto-approve
  terraform show
  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=disableSNAT.tfvars \
                  -auto-approve
  terraform show
  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=disableConnectedTransit.tfvars \
                  -auto-approve
  terraform show
  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=enableActiveMesh.tfvars \
                  -auto-approve
  terraform show
  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=updateGWSize.tfvars \
                  -auto-approve
  terraform show
  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=updateHAGWSize.tfvars \
                  -auto-approve
  terraform show

  terraform destroy -var-file=/path/provider_cred.tfvars -auto-approve
```
