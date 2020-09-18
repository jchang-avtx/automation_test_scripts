## aviatrix_gateway (VPN SAML)

### Test cases
- (Will repeat below for AWS GovCloud)
- updating VPN CIDRs
- updating search domains
- updating additional CIDRs
- updating name servers
- updating Single AZ HA mode
- updating Split Tunnel feature
- updating maximum allowed VPN connections
- updating VPN NAT status

- VPN GW with ELB
- multiple GWs under ELB
- VPN GW with no ELB in same region

---

### Usage
```
  terraform init
  terraform apply -var-file=/path/provider_cred.tfvars -auto-approve
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform state rm aviatrix_gateway.vpn_gw_1_under_elb
  terraform import -var-file=/path/provider_cred.tfvars aviatrix_gateway.vpn_gw_1_under_elb vpn-gw-1-under-elb
  terraform plan -var-file=/path/provider_cred.tfvars -detailed-exitcode
  terraform show

  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=updateVPNCIDR.tfvars \
                  -auto-approve
  terraform show
  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=updateSearchDomain.tfvars \
                  -auto-approve
  terraform show
  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=updateCIDRs.tfvars \
                  -auto-approve
  terraform show
  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=updateNameServers.tfvars \
                  -auto-approve
  terraform show
  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=disableSingleAZHA.tfvars \
                  -auto-approve
  terraform show
  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=disableSplitTunnel.tfvars \
                  -auto-approve
  terraform show
  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=updateMaxConn.tfvars \
                  -auto-approve
  terraform show
  terraform apply -var-file=/path/provider_cred.tfvars \
                  -var-file=disableVPNNAT.tfvars \
                  -auto-approve
  terraform show

  terraform destroy -var-file=/path/provider_cred.tfvars -auto-approve
```
