Usage
-----------
After creating a base Transit GW (using terraform.tfvars), the test files should be run in this order:
1. **updateTransitGW.tfvars**
  * will change the spoke_vpc to attach to another transit_vpc resource
2. **updateGWSize.tfvars**
  * will change the spoke GW's size from t2.micro to t2.small
3. **updateHAGWSize.tfvars**
  * will change the spoke HA GW's size from t2.micro to t2.small


* **emptycreation.tfvars**
  * Please see Mantis: id=8195 for reported refresh, update, and REST-API issues
  * (This is used to test invalid/ empty inputs; manual testing for Update cases as well)
