# =============================================================================
# Outputs
# =============================================================================

output "domain" {
  description = "Domain managed by the DNS module"
  value       = module.dns.domain
}

output "all_record_ids" {
  description = "All DNS record IDs organized by type"
  value       = module.dns.all_record_ids
}

output "record_count" {
  description = "Count of DNS records by type"
  value       = module.dns.record_count
}

output "a_records" {
  description = "A record details"
  value       = module.dns.a_records
}

output "cname_records" {
  description = "CNAME record details"
  value       = module.dns.cname_records
}

output "mx_records" {
  description = "MX record details"
  value       = module.dns.mx_records
}

output "txt_records" {
  description = "TXT record details"
  value       = module.dns.txt_records
}
