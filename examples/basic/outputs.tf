# =============================================================================
# Outputs
# =============================================================================

output "domain" {
  description = "Domain managed by the DNS module"
  value       = module.dns.domain
}

output "record_ids" {
  description = "All DNS record IDs"
  value       = module.dns.all_record_ids
}

output "record_count" {
  description = "Count of DNS records"
  value       = module.dns.record_count
}
