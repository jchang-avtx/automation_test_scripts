output "accountlist" {
  description = "Access accounts information"
  value       = ["${aviatrix_account.transit_access_account.*.account_name}"]
}
