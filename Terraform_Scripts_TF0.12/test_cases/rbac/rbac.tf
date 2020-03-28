## RBAC workflow

resource "aviatrix_account_user" "rbac_tf_export_user" {
  username    = "rbac-tf-export-user"
  email       = var.user_email
  password    = var.user_pass
}

resource "aviatrix_rbac_group" "rbac_tf_export_group" {
  group_name    = "rbac-tf-export-group"
}

resource "aviatrix_rbac_group_access_account_attachment" "rbac_tf_export_group_acc_att" {
  group_name              = aviatrix_rbac_group.rbac_tf_export_group.group_name
  access_account_name     = "all"
}

resource "aviatrix_rbac_group_permission_attachment" "rbac_tf_export_group_permission_att" {
  group_name          = aviatrix_rbac_group.rbac_tf_export_group.group_name
  permission_name     = "all_useful_tools_write"
}

resource "aviatrix_rbac_group_user_attachment" "rbac_tf_export_group_user_att" {
  group_name    = aviatrix_rbac_group.rbac_tf_export_group.group_name
  user_name     = aviatrix_account_user.rbac_tf_export_user.username
}

#################################################
# Outputs
#################################################
output "rbac_tf_export_user_id" {
  value = aviatrix_account_user.rbac_tf_export_user.id
}
output "rbac_tf_export_group_id" {
  value = aviatrix_rbac_group.rbac_tf_export_group.id
}
output "rbac_tf_export_group_acc_att_id" {
  value = aviatrix_rbac_group_access_account_attachment.rbac_tf_export_group_acc_att.id
}
output "rbac_tf_export_group_permission_att_id" {
  value = aviatrix_rbac_group_permission_attachment.rbac_tf_export_group_permission_att.id
}
output "rbac_tf_export_group_user_att_id" {
  value = aviatrix_rbac_group_user_attachment.rbac_tf_export_group_user_att.id
}
