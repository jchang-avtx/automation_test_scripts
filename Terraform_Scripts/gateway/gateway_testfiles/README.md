Usage
-----------
After creating a base profile to manipulate (using terraform.tfvars), the test files should be run in this order:
1. **switchaccountname.tfvars**
   * will switch access account names
   * Note: this function is not supported by Controller
2. **switchregion.tfvars**
   * will switch region and consequently the VPC ID; reverts test case 1
   * Note: this function is not supported by Controller
3. **switchsize.tfvars**
   * will revert the VPC ID and region to the actual controller (to refresh state) and change the instance size
4. **switchcidr.tfvars**
   * will change the CIDR / VPC_Net parameter
   * Note: this function is not supported by Controller

* **emptycreation.tfvars**
   * (This is used to test invalid/ empty inputs)

Running the scripts in this order will allow testing of manipulation of individual parameters.
You can switch around orders to do combinations of different updates.
