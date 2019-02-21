Usage
-----------
After creating a base profile to manipulate (using terraform.tfvars), the test files should be run in this order:
1. **switchaction.tfvars**
   * will swap all actions in policy rules
2. **switchport.tfvars**
   * will change all port numbers
3. **switchprotocol.tfvars**
   * will shift all protocols to the right by 1
4. **switchtarget.tfvars**
   * will increment all target IPs
5. **removeuser.tfvars**
   * will revert all previous changes and remove attached user
6. **changename.tfvars**
   * will change name of the VPN profile (not the id)
   * (Warning: this will bring about a bug; see id=7967)

* **emptycreation.tfvars**
   * (This is used to test invalid/ empty inputs; there are bugs; see id=7981 for empty input crash issue)
   * see id=8119 for issue with ICMP, ALL ports

Running the scripts in this order will allow testing of manipulation of individual parameters.
You can switch around orders to do combinations of different updates.
