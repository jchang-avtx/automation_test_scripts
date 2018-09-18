resource "aviatrix_firewall" "test_firewall" {
  gw_name = "FQDN-NAT-enabled"
  base_allow_deny = "allow"
  base_log_enable = "on"
  policy = [
            {
              protocol = "tcp"
              src_ip = "10.10.0.224/32"
              log_enable = "on"
              dst_ip = "10.20.0.172/32"
              allow_deny = "allow"
              port = "443"
            },
            {
              protocol = "tcp"
              src_ip = "10.10.1.10/32"
              log_enable = "off"
              dst_ip = "10.20.1.173/32"
              allow_deny = "allow"
              port = "500"
            },
            {
              protocol = "udp"
              src_ip = "10.10.0.2/32"
              log_enable = "on"
              dst_ip = "10.180.1.8/32"
              allow_deny = "allow"
              port = "4000"
            },
            {
              protocol = "icmp"
              src_ip = "172.10.10.10/32"
              log_enable = "on"
              dst_ip = "10.180.1.172/32"
              allow_deny = "allow"
              port = "1"
            },
            {
              protocol = "sctp"
              src_ip = "10.10.0.10/32"
              log_enable = "on"
              dst_ip = "10.10.10.172/32"
              allow_deny = "allow"
              port = "65535"
            },
            {
              protocol = "rdp"
              src_ip = "10.10.5.10/32"
              log_enable = "off"
              dst_ip = "10.12.6.172/32"
              allow_deny = "allow"
              port = "500"
            },
            {
              protocol = "dccp"
              src_ip = "10.10.9.10/32"
              log_enable = "on"
              dst_ip = "10.6.10.20/32"
              allow_deny = "allow"
              port = "65534"
            },
            {
              protocol = "icmp"
              src_ip = "10.10.10.180/32"
              log_enable = "off"
              dst_ip = "10.20.20.172/32"
              allow_deny = "allow"
              port = "1"
            }
          ]
}

resource "aviatrix_firewall_tag" "myown_tag" {
  firewall_tag = "firewall-tag"
  cidr_list = [
            {
              cidr_tag_name = "tag1"
              cidr = "10.12.0.172/32"
            },
            {
              cidr_tag_name = "tag2"
              cidr = "10.12.0.172/32"
            },
            {
              cidr_tag_name = "tag3"
              cidr = "10.12.0.172/32"
            },
            {
              cidr_tag_name = "tag4"
              cidr = "10.12.0.172/32"
            },
            {
              cidr_tag_name = "tag5"
              cidr = "10.12.0.172/32"
            },
            {
              cidr_tag_name = "tag6"
              cidr = "10.12.0.172/32"
            },
            {
              cidr_tag_name = "tag7"
              cidr = "10.12.0.172/32"
            },
            {
              cidr_tag_name = "tag8"
              cidr = "10.12.0.172/32"
            }
          ]
}

