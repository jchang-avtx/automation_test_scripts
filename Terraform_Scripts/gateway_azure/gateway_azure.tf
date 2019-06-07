# create an azure gateway

resource "aviatrix_gateway" "azure_gw" {
  cloud_type = 8
  account_name = "AzureAccess"
  gw_name = "azureGW"
  vpc_id = "VNet:ResourceGroup"
  vpc_reg = "Central US"
  vpc_size = "Standard_B1s"
  vpc_net = "10.2.0.0/24"

  peering_ha_subnet = "10.2.0.0/24"
  peering_ha_gw_size = "Standard_B1s"

  enable_nat = "yes"
  # single_az_ha = "enabled"

  # vpn_access = "yes"
  # vpn_cidr = "192.168.43.0/24"
  # enable_elb = "yes"
  # elb_name = "azureelb"
  # saml_enabled = "yes"

  ## Please see id = 9377
  # split_tunnel = "yes" # default is "yes"
  # name_servers = "1.1.1.1,199.85.126.10"
  # search_domains = "https://www.google.com"
  # additional_cidrs = "172.32.0.0/16,10.11.0.0/16"

  # otp_mode = "3"
  # okta_token = "OOOOOOOOoooooooTTTTTTTTTTTTTTTTTTTTTTTTken"
  # okta_url = "https://api-1234.okta.com"
  # okta_username_suffix = "okta-suffiXXXXXXXXXXXXXXX"

  # otp_mode = "2" # 2 = DUO ; 3 = Okta ; temporarily commented out because otp_mode lacking REST
  # duo_integration_key = "DDDDDDDDDDDDDDDDDD"
  # duo_secret_key = "QqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqXN2"
  # duo_api_hostname = "api-22222222.duosecurity.com"
  # duo_push_mode = "selective"
  #
  # enable_ldap = "yes"
  # ldap_server = "1.2.3.4:567"
  # ldap_bind_dn = "TTTTTTTTTEST\\Administratorr"
  # ldap_password = "myLDAPpassword1234"
  # ldap_base_dn = "DC=aviatrixtestt, DC=net"
  # ldap_username_attribute = "manual"

}
