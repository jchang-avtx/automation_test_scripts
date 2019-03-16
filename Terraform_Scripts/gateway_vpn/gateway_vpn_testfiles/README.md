Usage
-----------
After creating a base gateway to manipulate (using terraform.tfvars), the following test files may be run in any order:
1. **noSplitTunnel.tfvars**
  * test creation/ update of vpn gateway with no split tunnel
2. **updateGWandVPN.tfvars**
  * test updating gateway name and VPN_access parameters
  * should be run after initial creation
  * should fail
3. **enableELBnoVPN.tfvars**
  * test enabling ELB in creation, but not VPN_access
  * should fail
4. **enableELBwSplit.tfvars**
  * Test case: setting empty "elb_name" with "split_tunnel" enabled
  * Run this in conjunction with emptyELBwSplit.tf

* **emptycreation.tfvars**
   * (This is used to test empty input)
   * should pass because optional
