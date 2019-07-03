## Manages creation and management of Aviatrix Firewall Tags

resource "aviatrix_firewall_tag" "fw_tag_test" {
  firewall_tag    = "fw-tag-name"

  cidr_list {
    cidr_tag_name = var.cidr_list_tag_name[0]
    cidr          = var.cidr_list_cidr[0]
  }
  cidr_list {
    cidr_tag_name = var.cidr_list_tag_name[1]
    cidr          = var.cidr_list_cidr[1]
  }
  cidr_list {
    cidr_tag_name = var.cidr_list_tag_name[2]
    cidr          = var.cidr_list_cidr[2]
  }
  cidr_list {
    cidr_tag_name = var.cidr_list_tag_name[3]
    cidr          = var.cidr_list_cidr[3]
  }
  cidr_list {
    cidr_tag_name = var.cidr_list_tag_name[4]
    cidr          = var.cidr_list_cidr[4]
  }
  cidr_list {
    cidr_tag_name = var.cidr_list_tag_name[5]
    cidr          = var.cidr_list_cidr[5]
  }
  cidr_list {
    cidr_tag_name = var.cidr_list_tag_name[6]
    cidr          = var.cidr_list_cidr[6]
  }
  cidr_list {
    cidr_tag_name = var.cidr_list_tag_name[7]
    cidr          = var.cidr_list_cidr[7]
  }
}
