Usage
-----------
After creating a base gateway to manipulate (using terraform.tfvars), the test files should be run in the following order:
1. **updateVPNCIDR.tfvars**
  * will update VPN CIDR
2. **updateSearchDomain.tfvars**
  * will change search domain
3. **updateCIDRs.tfvars**
  * will remove a CIDR from the additional CIDR list
4. **updateNameServers.tfvars**
  * will remove a name server from the DNS list
5. **disableSingleAZHA.tfvars**
  * will disable_single_AZ_HA
6. **disableSplitTunnel.tfvars**
  * will disable split_tunnel
