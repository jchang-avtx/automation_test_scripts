output accountlist {
  description = "Access accounts information"
  value       = [aviatrix_account.aws_iam_access_account.*.account_name]
}
