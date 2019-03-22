Usage
-----------
After creating a base Transit GW (using terraform.tfvars), the test files should be run in this order:
1. **updateGWSize.tfvars**
  * will change the transit GW's size from t2.micro to t2.small
2. **updateHAGWSize.tfvars**
  * will change the transit HA GW's size from t2.micro to t2.small
3. **switchConnectedTransit.tfvars**
  * will turn off Connected Transit option
4. **disableHybrid.tfvars**
  * will disable "enable_hybrid_connection"; disables Step 5 in TGW Orchestrator > Plan


* **emptycreation.tfvars**
  * Please see Mantis: id=8192 for issue with ha_subnet, ha_gw_size
  * Please see Mantis: id=8209 for issues with refresh and update tests
  * (This is used to test invalid/ empty inputs; manual testing for Update cases as well)

Running the scripts in this order will allow testing of manipulation of individual parameters.
You can switch around orders to do combinations of different updates.
