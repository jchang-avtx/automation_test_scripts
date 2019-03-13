Usage
-----------
After creating a base case to manipulate (using terraform.tfvars), use any of the following test scripts:

1. **icmpNum.tfvars**
  * use to test firewall creation with icmp protocol with a port #
  * should fail
2. **icmpRange.tfvars**
  * use to test firewall creation with icmp protocol with a port range
  * should fail
3. **icmpPing.tfvars**
  * use to test firewall creation with icmp protocol with a port as ping
  * should fail
4. **icmpEmpty.tfvars**
  * use to test firewall creation with icmp protocol with an empty port
5. **icmpEmptyCreate.tfvars**
  * use to test firewall creation with icmp protocol and empty inputs


**emptycreation.tfvars**
  * Use to test invalid/ empty input cases
  * Can use this in conjunction with Case 1 (standard) and Case 3 (protocol all)
  * See usage in comment header
  * Known error - See Mantis: id = 8064

Note: Be sure to use the respective .tf files as there are 3 different test cases (standard, ICMP, all)

Only run **icmpXXX.tfvars** files in conjunction with Case 2 in firewall_icmp.tf
  * Known issue: id = 8063

As always, be sure to input your own valid login credentials when testing; do not upload here
