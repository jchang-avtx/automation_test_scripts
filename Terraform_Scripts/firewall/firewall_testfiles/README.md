Usage
-----------
After creating a base case to manipulate (using terraform.tfvars), use any of the following test scripts:
1. **icmponly.tfvars**
   * use this to manipulate the icmp test cases only; use in conjunction with Case 2 in firewall.tf
   * Known error - See Mantis: id = 8063
2. **emptycreation.tfvars**
   * Use to test invalid/ empty input cases
   * See usage in comment header
   * Known error - See Mantis: id = 8064

Note: Be sure to modify firewall.tf as it contains 3 different test cases. Please see comment blocks in file for details

As always, be sure to input your own valid login credentials when testing; do not upload here
