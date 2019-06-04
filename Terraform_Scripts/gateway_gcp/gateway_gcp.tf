resource "aviatrix_gateway" "gcloud_gw" {
  cloud_type = 4
  account_name = "GCPAccess"
  gw_name = "gcloudvpngw" # gcloudgw
  vpc_id = "gcptestvpc" # default
  vpc_reg = "us-west2-a"
  vpc_size = "f1-micro"
  vpc_net = "10.168.0.0/20"

  # enable_nat = "yes" # for gcp gw and spoke, only allowed if no HA (cannot have more than one SNAT GW)

  ## failed to update Aviatrix VPN Gateway Authentication: Rest API set_vpn_gateway_authentication Get failed: [Aviatrix Error] VPC ID does not exist in DB
  ## Please see id = 9377
  ## remember to comment out; peeringHA not supported on VPN gw (in general)
  vpn_access = "yes"
  vpn_cidr = "192.168.43.0/24"
  enable_elb = "yes" # required parameter when cloud type is 4
  elb_name = "gcp-elb"
  # saml_enabled = "yes"

  ## Please see id = 9377
  split_tunnel = "yes" # default is "yes"
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

  # enable_ldap = "yes"
  # ldap_server = "1.2.3.4:567"
  # ldap_bind_dn = "TTTTTTTTTEST\\Administratorr"
  # ldap_password = "myLDAPpassword1234"
  # ldap_base_dn = "DC=aviatrixtestt, DC=net"
  # ldap_username_attribute = "manual"


  ## Peering HA is not supported on VPN gw (in general)
  # peering_ha_subnet = "us-west2-b" ## this is not used in GCP gateway
  peering_ha_gw_size = "${var.gcp_ha_gw_size}"
  peering_ha_zone = "${var.gcp_ha_gw_zone}"
  # peering_ha_eip = "35.236.39.42" # not supported on GCP


  # single_az_ha = "enabled" # not supported in GCP

  allocate_new_eip = "on" # default is on
  # eip = "35.236.3.191" # not supported on GCP

  # tag_list = ["k1:v1"] # not supported on GCP
}
