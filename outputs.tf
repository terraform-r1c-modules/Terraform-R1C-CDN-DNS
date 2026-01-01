# =============================================================================
# Record IDs by Type
# =============================================================================

output "a_records" {
  description = "A record details including ID and name."
  value = {
    for name, record in arvancloud_cdn_domain_dns_record.a_records : name => {
      id   = record.id
      name = record.name
      type = record.type
    }
  }
}

output "aaaa_records" {
  description = "AAAA record details including ID and name."
  value = {
    for name, record in arvancloud_cdn_domain_dns_record.aaaa_records : name => {
      id   = record.id
      name = record.name
      type = record.type
    }
  }
}

output "aname_records" {
  description = "ANAME record details including ID and name."
  value = {
    for name, record in arvancloud_cdn_domain_dns_record.aname_records : name => {
      id   = record.id
      name = record.name
      type = record.type
    }
  }
}

output "caa_records" {
  description = "CAA record details including ID and name."
  value = {
    for name, record in arvancloud_cdn_domain_dns_record.caa_records : name => {
      id   = record.id
      name = record.name
      type = record.type
    }
  }
}

output "cname_records" {
  description = "CNAME record details including ID and name."
  value = {
    for name, record in arvancloud_cdn_domain_dns_record.cname_records : name => {
      id   = record.id
      name = record.name
      type = record.type
    }
  }
}

output "dkim_records" {
  description = "DKIM record details including ID and name."
  value = {
    for name, record in arvancloud_cdn_domain_dns_record.dkim_records : name => {
      id   = record.id
      name = record.name
      type = record.type
    }
  }
}

output "mx_records" {
  description = "MX record details including ID and name."
  value = {
    for name, record in arvancloud_cdn_domain_dns_record.mx_records : name => {
      id   = record.id
      name = record.name
      type = record.type
    }
  }
}

output "ns_records" {
  description = "NS record details including ID and name."
  value = {
    for name, record in arvancloud_cdn_domain_dns_record.ns_records : name => {
      id   = record.id
      name = record.name
      type = record.type
    }
  }
}

output "ptr_records" {
  description = "PTR record details including ID and name."
  value = {
    for name, record in arvancloud_cdn_domain_dns_record.ptr_records : name => {
      id   = record.id
      name = record.name
      type = record.type
    }
  }
}

output "spf_records" {
  description = "SPF record details including ID and name."
  value = {
    for name, record in arvancloud_cdn_domain_dns_record.spf_records : name => {
      id   = record.id
      name = record.name
      type = record.type
    }
  }
}

output "srv_records" {
  description = "SRV record details including ID and name."
  value = {
    for name, record in arvancloud_cdn_domain_dns_record.srv_records : name => {
      id   = record.id
      name = record.name
      type = record.type
    }
  }
}

output "tlsa_records" {
  description = "TLSA record details including ID and name."
  value = {
    for name, record in arvancloud_cdn_domain_dns_record.tlsa_records : name => {
      id   = record.id
      name = record.name
      type = record.type
    }
  }
}

output "txt_records" {
  description = "TXT record details including ID and name."
  value = {
    for name, record in arvancloud_cdn_domain_dns_record.txt_records : name => {
      id   = record.id
      name = record.name
      type = record.type
    }
  }
}

# =============================================================================
# Aggregated Outputs
# =============================================================================

output "all_record_ids" {
  description = "Map of all DNS record IDs organized by type."
  value = {
    a     = { for name, record in arvancloud_cdn_domain_dns_record.a_records : name => record.id }
    aaaa  = { for name, record in arvancloud_cdn_domain_dns_record.aaaa_records : name => record.id }
    aname = { for name, record in arvancloud_cdn_domain_dns_record.aname_records : name => record.id }
    caa   = { for name, record in arvancloud_cdn_domain_dns_record.caa_records : name => record.id }
    cname = { for name, record in arvancloud_cdn_domain_dns_record.cname_records : name => record.id }
    dkim  = { for name, record in arvancloud_cdn_domain_dns_record.dkim_records : name => record.id }
    mx    = { for name, record in arvancloud_cdn_domain_dns_record.mx_records : name => record.id }
    ns    = { for name, record in arvancloud_cdn_domain_dns_record.ns_records : name => record.id }
    ptr   = { for name, record in arvancloud_cdn_domain_dns_record.ptr_records : name => record.id }
    spf   = { for name, record in arvancloud_cdn_domain_dns_record.spf_records : name => record.id }
    srv   = { for name, record in arvancloud_cdn_domain_dns_record.srv_records : name => record.id }
    tlsa  = { for name, record in arvancloud_cdn_domain_dns_record.tlsa_records : name => record.id }
    txt   = { for name, record in arvancloud_cdn_domain_dns_record.txt_records : name => record.id }
  }
}

output "record_count" {
  description = "Count of DNS records by type."
  value = {
    a     = length(arvancloud_cdn_domain_dns_record.a_records)
    aaaa  = length(arvancloud_cdn_domain_dns_record.aaaa_records)
    aname = length(arvancloud_cdn_domain_dns_record.aname_records)
    caa   = length(arvancloud_cdn_domain_dns_record.caa_records)
    cname = length(arvancloud_cdn_domain_dns_record.cname_records)
    dkim  = length(arvancloud_cdn_domain_dns_record.dkim_records)
    mx    = length(arvancloud_cdn_domain_dns_record.mx_records)
    ns    = length(arvancloud_cdn_domain_dns_record.ns_records)
    ptr   = length(arvancloud_cdn_domain_dns_record.ptr_records)
    spf   = length(arvancloud_cdn_domain_dns_record.spf_records)
    srv   = length(arvancloud_cdn_domain_dns_record.srv_records)
    tlsa  = length(arvancloud_cdn_domain_dns_record.tlsa_records)
    txt   = length(arvancloud_cdn_domain_dns_record.txt_records)
    total = (
      length(arvancloud_cdn_domain_dns_record.a_records) +
      length(arvancloud_cdn_domain_dns_record.aaaa_records) +
      length(arvancloud_cdn_domain_dns_record.aname_records) +
      length(arvancloud_cdn_domain_dns_record.caa_records) +
      length(arvancloud_cdn_domain_dns_record.cname_records) +
      length(arvancloud_cdn_domain_dns_record.dkim_records) +
      length(arvancloud_cdn_domain_dns_record.mx_records) +
      length(arvancloud_cdn_domain_dns_record.ns_records) +
      length(arvancloud_cdn_domain_dns_record.ptr_records) +
      length(arvancloud_cdn_domain_dns_record.spf_records) +
      length(arvancloud_cdn_domain_dns_record.srv_records) +
      length(arvancloud_cdn_domain_dns_record.tlsa_records) +
      length(arvancloud_cdn_domain_dns_record.txt_records)
    )
  }
}
