# Usage
---

After creating a base TGW (using terraform.tfvars), the test files can be run in any order to manipulate update, empty/invalid test cases:

1. **switchSecDomain.tfvars**
  - will change Security Domains to test updating
2. **switchRegions.tfvars**
  - will change all region-related parameters to test updating
  - should be an invalid operation
3. **switchConnectDomain.tfvars**
  - will change connected domain to test updating
4. **switchAccountName.tfvars**
  - will change Aviatrix cloud account names
  - should be an invalid operation
5. **switchASN.tfvars**
  - will change BGP Local ASN
  - should be an invalid operation
6. **switchTGWname.tfvars**
  - will change AWS TGW after creation
  - should be an invalid operation

* **emptycreation.tfvars**
  * (This is used to test invalid/ empty inputs)
  * You must manually manipulate the values (comment/uncomment) to test either invalid/ empty inputs for various parameters
