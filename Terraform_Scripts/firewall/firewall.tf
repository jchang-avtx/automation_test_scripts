resource "aviatrix_firewall" "test_firewall" {
  gw_name = "FQDN-NAT-enabled"
  base_allow_deny = "allow"
  base_log_enable = "on"
  policy = [
            {
              protocol = "tcp"
              src_ip = "10.15.0.224/32"
              log_enable = "on"
              dst_ip = "10.12.0.172/32"
              allow_deny = "allow"
              port = "443"
            },
            {
              protocol = "tcp"
              src_ip = "10.10.10.10/32"
              log_enable = "off"
              dst_ip = "10.12.1.172/32"
              allow_deny = "deny"
              port = "500"
            },
            {
              protocol = "udp"
              src_ip = "10.10.10.10/32"
              log_enable = "off"
              dst_ip = "10.12.1.172/32"
              allow_deny = "allow"
              port = "4000"
            },
            {
              protocol = "icmp"
              src_ip = "10.10.10.10/32"
              log_enable = "off"
              dst_ip = "10.12.1.172/32"
              allow_deny = "deny"
              port = "500"
            },
            {
              protocol = "sctp"
              src_ip = "10.10.10.10/32"
              log_enable = "off"
              dst_ip = "10.12.1.172/32"
              allow_deny = "deny"
              port = "65535"
            },
            {
              protocol = "rdp"
              src_ip = "10.10.10.10/32"
              log_enable = "off"
              dst_ip = "10.12.1.172/32"
              allow_deny = "deny"
              port = "500"
            },
            {
              protocol = "dccp"
              src_ip = "10.10.10.10/32"
              log_enable = "off"
              dst_ip = "10.12.1.172/32"
              allow_deny = "deny"
              port = "65534"
            },
            {
              protocol = "icmp"
              src_ip = "10.10.10.10/32"
              log_enable = "off"
              dst_ip = "10.12.1.172/32"
              allow_deny = "deny"
              port = "1"
            }
          ]
}
