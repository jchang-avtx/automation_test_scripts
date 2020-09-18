## aviatrix_spoke_gateway

### Test cases
**Note:** For AWS and AWS GovCloud spoke gateways
- update which transit gateway to attach to
- update ActiveMesh and detach in same step
- reattach the transit
- update spoke gateway size
- update spoke HA gateway size
- enable DNS Server feature

---

### Usage
```
  terraform init
  terraform apply -var-file=/path/provider_cred.tfvars -auto-approve
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_spoke_gateway.aws_spoke_gateway
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_spoke_gateway.aws_spoke_gateway aws-spoke-gateway
  terraform plan -var-file=/path/provider_cred.tfvars // no -detailed-exitcode due to tag diffs
  terraform show

  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=updateTransitGW.tfvars \
                  -auto-approve
  terraform show
  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=detachActive.tfvars \
                  -auto-approve
  terraform show
  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=updateTransitGW.tfvars \
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
  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=enableDNSServer.tfvars \
                  -auto-approve
  terraform show

  terraform destroy -var-file=/path/provider_cred.tfvars -auto-approve
```
