## aviatrix_controller_config

---

### Usage
```
  terraform init
  terraform apply -var-file=/path/provider_cred.tfvars -auto-approve
  terraform plan -var-file=/path/provider_cred.tfvars
  terraform show

  terraform state rm aviatrix_controller_config.test_controller_config
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_controller_config.test_controller_config <IP>
  terraform plan -var-file=/path/provider_cred.tfvars
  terraform show

  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=enableHTTP.tfvars \
                  -auto-approve
  terraform show
  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=disableFQDN.tfvars \
                  -auto-approve
  terraform show
  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=disableSG.tfvars \
                  -auto-approve
  terraform show

  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=enableHTTP.tfvars \
                  -auto-approve
  terraform show

  // terraform destroy -var-file=/path/provider_cred.tfvars -auto-approve
```
