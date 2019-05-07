Usage
-----------
After creating a base Azure Spoke GW (using terraform.tfvars), the test files should be run in this order:

1. **disableSingleAZHA.tfvars**
  * disable single AZ HA to prep for HA gw
2. **enableHA.tfvars**
  * create HA spoke GW
3. **updateGWSize.tfvars**
  * will change the spoke GW's size from Standard_B1s to Standard_B1ms
4. **updateHAGWSize.tfvars**
  * will change the spoke HA GW's size from Standard_B1s to Standard_B1ms
5. **attachTransitGW.tfvars**
  * attach transit gw to spoke gw
6. **disableNAT.tfvars**
  * toggle off SNAT feature

Running the scripts in this order will allow testing of manipulation of individual parameters.
You can switch around orders to do combinations of different updates.
