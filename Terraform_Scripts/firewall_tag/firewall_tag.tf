resource "aviatrix_firewall_tag" "myown_tag" {
  firewall_tag = "edsel-tag"
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

