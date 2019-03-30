Usage
-----------
After creating a base FQDN GW with policies to manipulate (using terraform.tfvars), the test files should be run in this order:
1. **switchDomains.tfvars**
   * will change all domains in policy rules
2. **switchPorts.tfvars**
   * will change all port numbers
3. **switchProtocols.tfvars**
   * will change all protocols
4. **switchMode.tfvars**
   * will change from white to blacklist
5. **switchStatus.tfvars**
   * will change status from enabled to disabled
6. **switchGW.tfvars**
   * will add gateway to gateway list
7. **changeTagName.tfvars**
   * will change name of the fqdn filter (not id)
   * (will only fail if delta in state file is not rectified)
   * not supported


* **emptycreation.tfvars**
   * (This is used to test invalid/ empty inputs; there are bugs; see id=8002)

Running the scripts in this order will allow testing of manipulation of individual parameters.
You can switch around orders to do combinations of different updates.
