# Usage
---

After creating a base TGW (using terraform.tfvars), the test files can be run in any order to manipulate update, empty/invalid test cases:

1. **switchSecDomain.tfvars**
  - will change Security Domains to test updating
  - (updating a domain name is an invalid operation BUT attaching new or removing Security Domains are valid)
2. **switchRegions.tfvars**
  - will change all region-related parameters to test updating
  - should be an invalid operation
  - see id = 8428
3. **switchConnectDomain.tfvars**
  - will change connected domain to test updating
4. **switchVPC.tfvars**
  - will change attached VPC to another valid one.
  - switch VPC2 to VPC3
  - Note: VPC5 is the attached_vpc's, VPC4 is saved for manage_vpc_attachment
5. **switchAccountName.tfvars**
  - will change Aviatrix cloud account names
  - should be an invalid operation
  - see id = 8428
6. **switchASN.tfvars**
  - will change BGP Local ASN
  - should be an invalid operation
  - see id = 8428
7. **switchTGWname.tfvars**
  - will change AWS TGW after creation
  - should be an invalid operation

* **emptycreation.tfvars**
  * (This is used to test invalid/ empty inputs)
  * You must manually manipulate the values (comment/uncomment) to test either invalid/ empty inputs for various parameters
