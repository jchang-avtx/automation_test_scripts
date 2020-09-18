## aviatrix_spoke_gateway (customized routes)

### Test cases
**Note:**  All test cases on all cloud_types, except OCI due to non-official support for
- update customized spoke VPC routes
- update filtered spoke VPC routes
- update included advertise spoke routes

---

### Usage
```
  terraform init
  terraform apply -var-file=/path/provider_cred.tfvars -auto-approve
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_spoke_gateway.aws_custom_routes_spoke
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_spoke_gateway.aws_custom_routes_spoke aws-custom-routes-spoke
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_spoke_gateway.arm_custom_routes_spoke
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_spoke_gateway.arm_custom_routes_spoke arm-custom-routes-spoke
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_spoke_gateway.gcp_custom_routes_spoke
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_spoke_gateway.gcp_custom_routes_spoke gcp-custom-routes-spoke
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_spoke_gateway.oci_custom_routes_spoke
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_spoke_gateway.oci_custom_routes_spoke oci-custom-routes-spoke
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=updateCustomRoutes.tfvars \
                  -auto-approve
  terraform show
  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=updateFilterRoutes.tfvars \
                  -auto-approve
  terraform show
  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=updateIncludeAdvertiseRoutes.tfvars \
                  -auto-approve
  terraform show

  terraform destroy -var-file=/path/provider_cred.tfvars -auto-approve
```
