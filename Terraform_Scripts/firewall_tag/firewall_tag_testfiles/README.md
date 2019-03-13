Usage
-----
After creating a base case to manipulate (using terraform.tfvars), use any of the following test scripts:

1. **emptyCIDRTagName.tfvars**
  * use to test creating/ updating with empty CIDR tag name
  * should fail
2. **emptyCIDR.tfvars**
  * use to test creating/ updating with empty CIDR
  * should fail
3. **updateCIDRTagName.tfvars**
  * use to test updating an existing firewall_tag's cidr_tag names
4. **updateCIDR.tfvars**
  * use to test updating an existing firewall_tag's cidrs
5. **updateFWTagName.tfvars**
  * use to test updating an existing firewall_tag's name
  * should fail
