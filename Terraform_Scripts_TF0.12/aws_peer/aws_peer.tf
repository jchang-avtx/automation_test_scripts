## Create Aviatrix AWS Peering

resource "aviatrix_aws_peer" "test_awspeer" {
  account_name1 = var.avx_account_name_1
  account_name2 = var.avx_account_name_2

  vpc_id1       = var.aws_vpc_id_1
  vpc_id2       = var.aws_vpc_id_2
  vpc_reg1      = var.aws_vpc_region_1
  vpc_reg2      = var.aws_vpc_region_2
  rtb_list1     = var.aws_vpc_rtb_1
  rtb_list2     = var.aws_vpc_rtb_2
}

output "test_awspeer_id" {
  value = aviatrix_aws_peer.test_awspeer.id
}
