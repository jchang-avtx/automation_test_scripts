## Test case: stress test to verify high volume of firewall policy rules

variable "max_rule" {
  default = 100
}

resource "random_integer" "src_ip1" {
  count = var.max_rule
  min = 1
  max = 126
}

resource "random_integer" "src_ip2" {
  count = var.max_rule
  min = 1
  max = 126
}

resource "random_integer" "dst_ip1" {
  count = var.max_rule
  min = 1
  max = 126
}

resource "random_integer" "dst_ip2" {
  count = var.max_rule
  min = 1
  max = 126
}

resource "random_shuffle" "protocol" {
  count = var.max_rule
  input = ["tcp", "udp", "sctp", "rdp", "dccp"]
}

resource "random_integer" "port" {
  count = var.max_rule
  min = 1
  max = 1000
}


resource "aviatrix_firewall" "stress_firewall" {
  gw_name = aviatrix_gateway.test_gateway["firewallGW3"].gw_name
  base_policy = "allow-all"
  base_log_enabled = true

  dynamic "policy" {
    for_each = range(var.max_rule)
    content {
      src_ip = join(".", [random_integer.src_ip1[policy.value].result, random_integer.src_ip2[policy.value].result, "0.0/16"])
      dst_ip = join(".", [random_integer.dst_ip1[policy.value].result, random_integer.dst_ip2[policy.value].result, "0.0/16"])
      protocol = random_shuffle.protocol[policy.value].result[0]
      port = random_integer.port[policy.value].result
      action = "allow"
      log_enabled = true
    }
  }
}

output "stress_firewall_id" {
  value = aviatrix_firewall.stress_firewall.id
}

## Data source
data "aviatrix_firewall" "d_stress_firewall" {
  gw_name = aviatrix_gateway.test_gateway["firewallGW3"].gw_name
  depends_on = [aviatrix_firewall.stress_firewall]
}

output "d_stress_firewall_id" {
  value = data.aviatrix_firewall.d_stress_firewall.id
}
