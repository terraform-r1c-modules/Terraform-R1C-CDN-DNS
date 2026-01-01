locals {
  # Default values for optional configurations
  default_ip_filter_mode = {
    count      = "single"
    order      = "none"
    geo_filter = "none"
  }

  default_upstream_https = "default"
  default_ttl            = 120

  # Create indexed records list with unique keys
  # Key format: {name}_{type}_{index} to handle duplicates
  indexed_records = [
    for idx, record in var.records : merge(record, {
      unique_key = record.key != null ? record.key : "${record.name}_${record.type}_${idx}"
    })
  ]

  # Categorize records by type for efficient processing (using unique keys)
  a_records     = { for record in local.indexed_records : record.unique_key => record if record.type == "a" }
  aaaa_records  = { for record in local.indexed_records : record.unique_key => record if record.type == "aaaa" }
  aname_records = { for record in local.indexed_records : record.unique_key => record if record.type == "aname" }
  caa_records   = { for record in local.indexed_records : record.unique_key => record if record.type == "caa" }
  cname_records = { for record in local.indexed_records : record.unique_key => record if record.type == "cname" }
  dkim_records  = { for record in local.indexed_records : record.unique_key => record if record.type == "dkim" }
  mx_records    = { for record in local.indexed_records : record.unique_key => record if record.type == "mx" }
  ns_records    = { for record in local.indexed_records : record.unique_key => record if record.type == "ns" }
  ptr_records   = { for record in local.indexed_records : record.unique_key => record if record.type == "ptr" }
  spf_records   = { for record in local.indexed_records : record.unique_key => record if record.type == "spf" }
  srv_records   = { for record in local.indexed_records : record.unique_key => record if record.type == "srv" }
  tlsa_records  = { for record in local.indexed_records : record.unique_key => record if record.type == "tlsa" }
  txt_records   = { for record in local.indexed_records : record.unique_key => record if record.type == "txt" }
}

# =============================================================================
# A Records - IPv4 addresses
# =============================================================================
resource "arvancloud_cdn_domain_dns_record" "a_records" {
  for_each = local.a_records

  domain         = var.domain
  name           = each.value.name
  ttl            = coalesce(each.value.ttl, local.default_ttl)
  cloud          = coalesce(each.value.cloud, true)
  upstream_https = coalesce(each.value.upstream_https, local.default_upstream_https)
  type           = "a"

  ip_filter_mode = each.value.ip_filter_mode != null ? each.value.ip_filter_mode : local.default_ip_filter_mode

  value = {
    a = [
      for a in each.value.value.a : {
        ip      = a.ip
        port    = a.port
        weight  = a.weight
        country = a.country
      }
    ]
  }
}

# =============================================================================
# AAAA Records - IPv6 addresses
# =============================================================================
resource "arvancloud_cdn_domain_dns_record" "aaaa_records" {
  for_each = local.aaaa_records

  domain         = var.domain
  name           = each.value.name
  ttl            = coalesce(each.value.ttl, local.default_ttl)
  cloud          = coalesce(each.value.cloud, true)
  upstream_https = coalesce(each.value.upstream_https, local.default_upstream_https)
  type           = "aaaa"

  ip_filter_mode = each.value.ip_filter_mode != null ? each.value.ip_filter_mode : local.default_ip_filter_mode

  value = {
    aaaa = [
      for aaaa in each.value.value.aaaa : {
        ip      = aaaa.ip
        port    = aaaa.port
        weight  = aaaa.weight
        country = aaaa.country
      }
    ]
  }
}

# =============================================================================
# ANAME Records - Alias records
# =============================================================================
resource "arvancloud_cdn_domain_dns_record" "aname_records" {
  for_each = local.aname_records

  domain         = var.domain
  name           = each.value.name
  ttl            = coalesce(each.value.ttl, local.default_ttl)
  cloud          = coalesce(each.value.cloud, true)
  upstream_https = coalesce(each.value.upstream_https, local.default_upstream_https)
  type           = "aname"

  ip_filter_mode = each.value.ip_filter_mode != null ? each.value.ip_filter_mode : local.default_ip_filter_mode

  value = {
    aname = {
      location    = each.value.value.aname.location
      host_header = each.value.value.aname.host_header
      port        = each.value.value.aname.port
    }
  }
}

# =============================================================================
# CAA Records - Certificate Authority Authorization
# =============================================================================
resource "arvancloud_cdn_domain_dns_record" "caa_records" {
  for_each = local.caa_records

  domain         = var.domain
  name           = each.value.name
  ttl            = coalesce(each.value.ttl, local.default_ttl)
  cloud          = coalesce(each.value.cloud, false)
  upstream_https = coalesce(each.value.upstream_https, local.default_upstream_https)
  type           = "caa"

  ip_filter_mode = each.value.ip_filter_mode != null ? each.value.ip_filter_mode : local.default_ip_filter_mode

  value = {
    caa = {
      tag   = each.value.value.caa.tag
      value = each.value.value.caa.value
    }
  }
}

# =============================================================================
# CNAME Records - Canonical name records
# =============================================================================
resource "arvancloud_cdn_domain_dns_record" "cname_records" {
  for_each = local.cname_records

  domain         = var.domain
  name           = each.value.name
  ttl            = coalesce(each.value.ttl, local.default_ttl)
  cloud          = coalesce(each.value.cloud, true)
  upstream_https = coalesce(each.value.upstream_https, local.default_upstream_https)
  type           = "cname"

  ip_filter_mode = each.value.ip_filter_mode != null ? each.value.ip_filter_mode : local.default_ip_filter_mode

  value = {
    cname = {
      host        = each.value.value.cname.host
      host_header = each.value.value.cname.host_header
      port        = each.value.value.cname.port
    }
  }
}

# =============================================================================
# DKIM Records - DomainKeys Identified Mail
# =============================================================================
resource "arvancloud_cdn_domain_dns_record" "dkim_records" {
  for_each = local.dkim_records

  domain         = var.domain
  name           = each.value.name
  ttl            = coalesce(each.value.ttl, local.default_ttl)
  cloud          = coalesce(each.value.cloud, false)
  upstream_https = coalesce(each.value.upstream_https, local.default_upstream_https)
  type           = "dkim"

  ip_filter_mode = each.value.ip_filter_mode != null ? each.value.ip_filter_mode : local.default_ip_filter_mode

  value = {
    dkim = {
      text = each.value.value.dkim.text
    }
  }
}

# =============================================================================
# MX Records - Mail Exchange
# =============================================================================
resource "arvancloud_cdn_domain_dns_record" "mx_records" {
  for_each = local.mx_records

  domain         = var.domain
  name           = each.value.name
  ttl            = coalesce(each.value.ttl, local.default_ttl)
  cloud          = coalesce(each.value.cloud, false)
  upstream_https = coalesce(each.value.upstream_https, local.default_upstream_https)
  type           = "mx"

  ip_filter_mode = each.value.ip_filter_mode != null ? each.value.ip_filter_mode : local.default_ip_filter_mode

  value = {
    mx = {
      host     = each.value.value.mx.host
      priority = each.value.value.mx.priority
    }
  }
}

# =============================================================================
# NS Records - Name Server
# =============================================================================
resource "arvancloud_cdn_domain_dns_record" "ns_records" {
  for_each = local.ns_records

  domain         = var.domain
  name           = each.value.name
  ttl            = coalesce(each.value.ttl, local.default_ttl)
  cloud          = coalesce(each.value.cloud, false)
  upstream_https = coalesce(each.value.upstream_https, local.default_upstream_https)
  type           = "ns"

  ip_filter_mode = each.value.ip_filter_mode != null ? each.value.ip_filter_mode : local.default_ip_filter_mode

  value = {
    ns = {
      host = each.value.value.ns.host
    }
  }
}

# =============================================================================
# PTR Records - Pointer records for reverse DNS
# =============================================================================
resource "arvancloud_cdn_domain_dns_record" "ptr_records" {
  for_each = local.ptr_records

  domain         = var.domain
  name           = each.value.name
  ttl            = coalesce(each.value.ttl, local.default_ttl)
  cloud          = coalesce(each.value.cloud, false)
  upstream_https = coalesce(each.value.upstream_https, local.default_upstream_https)
  type           = "ptr"

  ip_filter_mode = each.value.ip_filter_mode != null ? each.value.ip_filter_mode : local.default_ip_filter_mode

  value = {
    ptr = {
      domain = each.value.value.ptr.domain
    }
  }
}

# =============================================================================
# SPF Records - Sender Policy Framework
# =============================================================================
resource "arvancloud_cdn_domain_dns_record" "spf_records" {
  for_each = local.spf_records

  domain         = var.domain
  name           = each.value.name
  ttl            = coalesce(each.value.ttl, local.default_ttl)
  cloud          = coalesce(each.value.cloud, false)
  upstream_https = coalesce(each.value.upstream_https, local.default_upstream_https)
  type           = "spf"

  ip_filter_mode = each.value.ip_filter_mode != null ? each.value.ip_filter_mode : local.default_ip_filter_mode

  value = {
    spf = {
      text = each.value.value.spf.text
    }
  }
}

# =============================================================================
# SRV Records - Service records
# =============================================================================
resource "arvancloud_cdn_domain_dns_record" "srv_records" {
  for_each = local.srv_records

  domain         = var.domain
  name           = each.value.name
  ttl            = coalesce(each.value.ttl, local.default_ttl)
  cloud          = coalesce(each.value.cloud, false)
  upstream_https = coalesce(each.value.upstream_https, local.default_upstream_https)
  type           = "srv"

  ip_filter_mode = each.value.ip_filter_mode != null ? each.value.ip_filter_mode : local.default_ip_filter_mode

  value = {
    srv = {
      target   = each.value.value.srv.target
      port     = each.value.value.srv.port
      priority = each.value.value.srv.priority
      weight   = each.value.value.srv.weight
    }
  }
}

# =============================================================================
# TLSA Records - TLS Authentication
# =============================================================================
resource "arvancloud_cdn_domain_dns_record" "tlsa_records" {
  for_each = local.tlsa_records

  domain         = var.domain
  name           = each.value.name
  ttl            = coalesce(each.value.ttl, local.default_ttl)
  cloud          = coalesce(each.value.cloud, false)
  upstream_https = coalesce(each.value.upstream_https, local.default_upstream_https)
  type           = "tlsa"

  ip_filter_mode = each.value.ip_filter_mode != null ? each.value.ip_filter_mode : local.default_ip_filter_mode

  value = {
    tlsa = {
      usage         = each.value.value.tlsa.usage
      selector      = each.value.value.tlsa.selector
      matching_type = each.value.value.tlsa.matching_type
      certificate   = each.value.value.tlsa.certificate
    }
  }
}

# =============================================================================
# TXT Records - Text records
# =============================================================================
resource "arvancloud_cdn_domain_dns_record" "txt_records" {
  for_each = local.txt_records

  domain         = var.domain
  name           = each.value.name
  ttl            = coalesce(each.value.ttl, local.default_ttl)
  cloud          = coalesce(each.value.cloud, false)
  upstream_https = coalesce(each.value.upstream_https, local.default_upstream_https)
  type           = "txt"

  ip_filter_mode = each.value.ip_filter_mode != null ? each.value.ip_filter_mode : local.default_ip_filter_mode

  value = {
    txt = {
      text = each.value.value.txt.text
    }
  }
}
