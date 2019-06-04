Usage
-----------
* **toggleCIDRAdvert.tfvars**
  * Run this after initial creation
  * As of current writing (4.6 release), the only 2 attributes that can be edited are:
    * *enable_advertise_transit_cidr*
    * *bgp_manual_spoke_advertise_cidrs*

* **emptycreation.tfvars**
   * (This is used to test invalid/ empty inputs)
   * Has been modified to also test for update test cases
   * Mantis issues stated inside, if any

Please see file for more specific instructions on variable manipulation
