Usage
-----------
After creating a base Azure Transit GW (using terraform.tfvars), the test files should be run in this order:

1. **switchConnectedTransit.tfvars**
  * will turn off Connected Transit option
2. **disableHybrid.tfvars**
  * will disable "enable_hybrid_connection"; disables Step 5 in TGW Orchestrator > Plan
  * EDIT: This feature not supported on Azure as of (18 Apr 2019)
3. **updateGWSize.tfvars**
  * will change the transit GW's size from Standard_B1s to Standard_B1ms
4. **updateHAGWSize.tfvars**
  * will change the transit HA GW's size from Standard_B1s to Standard_B1ms

Running the scripts in this order will allow testing of manipulation of individual parameters.
You can switch around orders to do combinations of different updates.
