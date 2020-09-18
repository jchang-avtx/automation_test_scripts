## aviatrix_aws_tgw

---

### Test cases
- multicasted TGW
- swap connected Security Domains
- update custom routes
- swap between connected VPCs
- check local route propagation
- manage transit gateway attachments separately
- integrated TGW VPN conn testing + learned CIDR approval switch
- repeat above for AWS GovCloud


### Usage
```
  terraform init
  terraform apply -var-file=/path/provider_cred.tfvars -auto-approve
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_aws_tgw.test_aws_tgw
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_aws_tgw.test_aws_tgw test-aws-tgw
  terraform plan -var-file=/path/provider_cred.tfvars
  terraform show

  terraform state rm aviatrix_aws_tgw_transit_gateway_attachment.tgw_transit_att
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_aws_tgw_transit_gateway_attachment.tgw_transit_att id
  terraform plan -var-file=/path/provider_cred.tfvars
  terraform show

  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=switchConnectDomain.tfvars \
                  -auto-approve
  terraform show
  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=switchVPC.tfvars \
                  -auto-approve
  terraform show
  <!-- terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=updateCustomRoutes.tfvars \
                  -auto-approve
  terraform show
  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=enableLocalRouteProp.tfvars \
                  -auto-approve
  terraform show -->

  // do not destroy; use for tgw_vpn_conn
  // terraform destroy -var-file=/path/provider_cred.tfvars -auto-approve
```
