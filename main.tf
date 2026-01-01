resource "cdn_domain_dns_record" "a_records" {
  for_each       = { for record in var.records : record.name => record if record.type == "a" }
  domain         = var.domain
  name           = each.value.name
  ttl            = each.value.ttl
  cloud          = each.value.cloud
  upstream_https = each.value.upstream_https
  ip_filter_mode = each.value.ip_filter_mode
  type           = each.value.type
  value = {
    a = [
      for a in each.value.value.a : {
        ip     = a.ip
        port   = a.port
        weight = a.weight
      }
    ]
  }
}

resource "cdn_domain_dns_record" "aaaa_records" {
  for_each = { for record in var.records : record.name => record if record.type == "aaaa" }

  domain         = var.domain
  name           = each.value.name
  ttl            = each.value.ttl
  cloud          = each.value.cloud
  upstream_https = each.value.upstream_https
  ip_filter_mode = each.value.ip_filter_mode
  type           = each.value.type
  value = {
    aaaa = [
      for aaaa in each.value.value.aaaa : {
        ip     = aaaa.ip
        port   = aaaa.port
        weight = aaaa.weight
      }
    ]
  }
}

resource "cdn_domain_dns_record" "aname_records" {
  for_each = { for record in var.records : record.name => record if record.type == "aname" }

  domain         = var.domain
  name           = each.value.name
  ttl            = each.value.ttl
  cloud          = each.value.cloud
  upstream_https = each.value.upstream_https
  ip_filter_mode = each.value.ip_filter_mode
  type           = each.value.type
  value = {
    aname = {
      host_header = each.value.value.aname.host_header
      location    = each.value.value.aname.location
      port        = each.value.value.aname.port
    }
  }
}

resource "cdn_domain_dns_record" "caa_records" {
  for_each = { for record in var.records : record.name => record if record.type == "caa" }

  domain         = var.domain
  name           = each.value.name
  ttl            = each.value.ttl
  cloud          = each.value.cloud
  upstream_https = each.value.upstream_https
  ip_filter_mode = each.value.ip_filter_mode
  type           = each.value.type
  value = {
    caa = {
      tag   = each.value.value.caa.tag
      value = each.value.value.caa.value
    }
  }
}

resource "cdn_domain_dns_record" "cname_records" {
  for_each = { for record in var.records : record.name => record if record.type == "cname" }

  domain         = var.domain
  name           = each.value.name
  ttl            = each.value.ttl
  cloud          = each.value.cloud
  upstream_https = each.value.upstream_https
  ip_filter_mode = each.value.ip_filter_mode
  type           = each.value.type
  value = {
    cname = {
      host        = each.value.value.cname.host
      host_header = each.value.value.cname.host_header
      port        = each.value.value.cname.port
    }
  }
}

resource "cdn_domain_dns_record" "dkim_records" {
  for_each = { for record in var.records : record.name => record if record.type == "dkim" }

  domain         = var.domain
  name           = each.value.name
  ttl            = each.value.ttl
  cloud          = each.value.cloud
  upstream_https = each.value.upstream_https
  ip_filter_mode = each.value.ip_filter_mode
  type           = each.value.type
  value = {
    dkim = {
      text = each.value.value.dkim.text
    }
  }
}

resource "cdn_domain_dns_record" "mx_records" {
  for_each = { for record in var.records : record.name => record if record.type == "mx" }

  domain         = var.domain
  name           = each.value.name
  ttl            = each.value.ttl
  cloud          = each.value.cloud
  upstream_https = each.value.upstream_https
  ip_filter_mode = each.value.ip_filter_mode
  type           = each.value.type
  value = {
    mx = {
      priority = each.value.value.mx.priority
      host     = each.value.value.mx.host
    }
  }
}

resource "cdn_domain_dns_record" "ns_records" {
  for_each = { for record in var.records : record.name => record if record.type == "ns" }

  domain         = var.domain
  name           = each.value.name
  ttl            = each.value.ttl
  cloud          = each.value.cloud
  upstream_https = each.value.upstream_https
  ip_filter_mode = each.value.ip_filter_mode
  type           = each.value.type
  value = {
    ns = {
      host = each.value.value.ns.host
    }
  }
}

resource "cdn_domain_dns_record" "ptr_records" {
  for_each = { for record in var.records : record.name => record if record.type == "ptr" }

  domain         = var.domain
  name           = each.value.name
  ttl            = each.value.ttl
  cloud          = each.value.cloud
  upstream_https = each.value.upstream_https
  ip_filter_mode = each.value.ip_filter_mode
  type           = each.value.type
  value = {
    ptr = {
      domain = each.value.value.ptr.domain
    }
  }
}

resource "cdn_domain_dns_record" "spf_records" {
  for_each = { for record in var.records : record.name => record if record.type == "spf" }

  domain         = var.domain
  name           = each.value.name
  ttl            = each.value.ttl
  cloud          = each.value.cloud
  upstream_https = each.value.upstream_https
  ip_filter_mode = each.value.ip_filter_mode
  type           = each.value.type
  value = {
    spf = {
      text     = each.value.value.spf.text
      port     = each.value.value.spf.port
      priority = each.value.value.spf.priority
    }
  }
}


resource "cdn_domain_dns_record" "srv_records" {
  for_each = { for record in var.records : record.name => record if record.type == "srv" }

  domain         = var.domain
  name           = each.value.name
  ttl            = each.value.ttl
  cloud          = each.value.cloud
  upstream_https = each.value.upstream_https
  ip_filter_mode = each.value.ip_filter_mode
  type           = each.value.type
  value = {
    srv = {
      target   = each.value.value.srv.target
      port     = each.value.value.srv.port
      priority = each.value.value.srv.priority
      weight   = each.value.value.srv.weight
    }
  }
}

resource "cdn_domain_dns_record" "tlsa_records" {
  for_each = { for record in var.records : record.name => record if record.type == "tlsa" }

  domain         = var.domain
  name           = each.value.name
  ttl            = each.value.ttl
  cloud          = each.value.cloud
  upstream_https = each.value.upstream_https
  ip_filter_mode = each.value.ip_filter_mode
  type           = each.value.type
  value = {
    tlsa = {
      certificate   = each.value.value.tlsa.certificate
      matching_type = each.value.value.tlsa.matching_type
      selector      = each.value.value.tlsa.selector
      usage         = each.value.value.tlsa.usage
    }
  }
}


resource "cdn_domain_dns_record" "txt_records" {
  for_each = { for record in var.records : record.name => record if record.type == "txt" }

  domain         = var.domain
  name           = each.value.name
  ttl            = each.value.ttl
  cloud          = each.value.cloud
  upstream_https = each.value.upstream_https
  ip_filter_mode = each.value.ip_filter_mode
  type           = each.value.type
  value = {
    txt = {
      text = each.value.value.txt.text
    }
  }
}
