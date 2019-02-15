## initial creation for Aviatrix customer_id management
## This file is also used to test Update/ refresh test case;; See sections for Valid Input
## This file is also used to test invalid/ empty input test case;; See section for Invalid Input

aviatrix_controller_ip = "1.2.3.4"
aviatrix_controller_username = "admin"
aviatrix_controller_password = "password"
##############################################
## VALID INPUT
##############################################

# aviatrix_customer_id = "validCustomer-1234.56"
# aviatrix_customer_id = "validCustomer-7890.12" # Input second valid customerID to test Update

##############################################
## EMPTY / INVALID INPUT
##############################################

# aviatrix_customer_id = "" # empty; cust_id req
# aviatrix_customer_id = "user-1234.56" # invalid; cannot
