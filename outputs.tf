output "a_records_id" {
  description = "The ID of A DNS records"
  value = {
    for name, record in cdn_domain_dns_record.a_records : name => record.id
  }
}

output "aaaa_records_id" {
  description = "The ID of AAAA DNS records"
  value = {
    for name, record in cdn_domain_dns_record.aaaa_records : name => record.id
  }
}

output "aname_records_id" {
  description = "The ID of ANAME DNS records"
  value = {
    for name, record in cdn_domain_dns_record.aname_records : name => record.id
  }
}

output "caa_records_id" {
  description = "The ID of CAA DNS records"
  value = {
    for name, record in cdn_domain_dns_record.caa_records : name => record.id
  }
}

output "cname_records_id" {
  description = "The ID of CNAME DNS records"
  value = {
    for name, record in cdn_domain_dns_record.cname_records : name => record.id
  }
}

output "dkim_records_id" {
  description = "The ID of DKIM DNS records"
  value = {
    for name, record in cdn_domain_dns_record.dkim_records : name => record.id
  }
}

output "mx_records_id" {
  description = "The ID of MX DNS records"
  value = {
    for name, record in cdn_domain_dns_record.mx_records : name => record.id
  }
}

output "ns_records_id" {
  description = "The ID of NS DNS records"
  value = {
    for name, record in cdn_domain_dns_record.ns_records : name => record.id
  }
}

output "ptr_records_id" {
  description = "The ID of PTR DNS records"
  value = {
    for name, record in cdn_domain_dns_record.ptr_records : name => record.id
  }
}

output "spf_records_id" {
  description = "The ID of SPF DNS records"
  value = {
    for name, record in cdn_domain_dns_record.spf_records : name => record.id
  }
}

output "srv_records_id" {
  description = "The ID of SRV DNS records"
  value = {
    for name, record in cdn_domain_dns_record.srv_records : name => record.id
  }
}

output "tlsa_records_id" {
  description = "The ID of TLSA DNS records"
  value = {
    for name, record in cdn_domain_dns_record.tlsa_records : name => record.id
  }
}

output "txt_records_id" {
  description = "The ID of TXT DNS records"
  value = {
    for name, record in cdn_domain_dns_record.txt_records : name => record.id
  }
}
