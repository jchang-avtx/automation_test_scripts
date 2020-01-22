## aviatrix_tunnel

---

### Usage
```
  terraform init
  terraform apply -var-file=/path/provider_cred.tfvars -auto-approve
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_tunnel.peeringTunnel
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_tunnel.peeringTunnel peeringGW1~peeringGW2
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform destroy -var-file=/path/provider_cred.tfvars -auto-approve
```
