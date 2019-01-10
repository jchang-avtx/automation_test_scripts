output "accountlist" {
  description = "Access accounts information"
  value       = ["${aviatrix_account.access.*.account_name}"]
}
