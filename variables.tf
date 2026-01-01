# =============================================================================
# Domain Configuration
# =============================================================================

variable "domain" {
  description = "The domain name (UUID or name) for the DNS zone."
  type        = string

  validation {
    condition     = length(var.domain) > 0
    error_message = "Domain name cannot be empty."
  }
}

# =============================================================================
# DNS Records Configuration
# =============================================================================

variable "records" {
  description = <<-EOT
    List of DNS records to create. Each record requires a name and type.
    Optional fields will use sensible defaults if not provided.

    Supported record types:
    - a, aaaa: IP address records (supports multiple IPs with optional port, weight, country)
    - aname: Alias records (requires location, host_header)
    - caa: Certificate Authority Authorization (requires tag, value)
    - cname: Canonical name records (requires host, host_header)
    - dkim: DomainKeys Identified Mail (requires text)
    - mx: Mail Exchange (requires host, priority)
    - ns: Name Server (requires host)
    - ptr: Pointer records (requires domain)
    - spf: Sender Policy Framework (requires text)
    - srv: Service records (requires target, port, priority, weight)
    - tlsa: TLS Authentication (requires usage, selector, matching_type, certificate)
    - txt: Text records (requires text)
  EOT

  type = list(object({
    # Required fields
    name = string
    type = string

    # Optional unique key for records with duplicate names (e.g., multiple @ TXT records)
    # If not provided, a unique key will be auto-generated as: {name}_{type}_{index}
    key = optional(string)

    # Optional fields with defaults
    ttl            = optional(number)
    cloud          = optional(bool)
    upstream_https = optional(string)

    # IP filter mode configuration (optional)
    ip_filter_mode = optional(object({
      count      = optional(string, "single")
      order      = optional(string, "none")
      geo_filter = optional(string, "none")
    }))

    # Record value - only the matching type field is required
    value = object({
      # A record - list of IPv4 addresses
      a = optional(list(object({
        ip      = string
        country = optional(string)
        port    = optional(number)
        weight  = optional(number)
      })))

      # AAAA record - list of IPv6 addresses
      aaaa = optional(list(object({
        ip      = string
        country = optional(string)
        port    = optional(number)
        weight  = optional(number)
      })))

      # ANAME record - alias to another domain
      aname = optional(object({
        location    = string
        host_header = string
        port        = optional(number)
      }))

      # CAA record - Certificate Authority Authorization
      caa = optional(object({
        tag   = string
        value = string
      }))

      # CNAME record - canonical name
      cname = optional(object({
        host        = string
        host_header = string
        port        = optional(number)
      }))

      # DKIM record - DomainKeys Identified Mail
      dkim = optional(object({
        text = string
      }))

      # MX record - mail exchange
      mx = optional(object({
        host     = string
        priority = number
      }))

      # NS record - name server
      ns = optional(object({
        host = string
      }))

      # PTR record - pointer for reverse DNS
      ptr = optional(object({
        domain = string
      }))

      # SPF record - Sender Policy Framework
      spf = optional(object({
        text = string
      }))

      # SRV record - service location
      srv = optional(object({
        target   = string
        port     = optional(number)
        priority = optional(number)
        weight   = optional(number)
      }))

      # TLSA record - TLS Authentication
      tlsa = optional(object({
        usage         = string
        selector      = string
        matching_type = string
        certificate   = string
      }))

      # TXT record - arbitrary text
      txt = optional(object({
        text = string
      }))
    })
  }))

  default = []

  validation {
    condition = alltrue([
      for record in var.records :
      contains(["a", "aaaa", "aname", "caa", "cname", "dkim", "mx", "ns", "ptr", "spf", "srv", "tlsa", "txt"], record.type)
    ])
    error_message = "Record type must be one of: a, aaaa, aname, caa, cname, dkim, mx, ns, ptr, spf, srv, tlsa, txt."
  }

  validation {
    condition = alltrue([
      for record in var.records :
      record.name != null && length(record.name) > 0
    ])
    error_message = "Record name cannot be empty."
  }

  validation {
    condition = alltrue([
      for record in var.records :
      record.ttl == null || (record.ttl >= 60 && record.ttl <= 86400)
    ])
    error_message = "TTL must be between 60 and 86400 seconds when specified."
  }

  validation {
    condition = alltrue([
      for record in var.records :
      record.upstream_https == null || contains(["default", "auto", "http", "https"], record.upstream_https)
    ])
    error_message = "upstream_https must be one of: default, auto, http, https."
  }

  validation {
    condition = alltrue([
      for record in var.records :
      record.ip_filter_mode == null || (
        (record.ip_filter_mode.count == null || contains(["single", "multi"], record.ip_filter_mode.count)) &&
        (record.ip_filter_mode.order == null || contains(["none", "weighted", "rr"], record.ip_filter_mode.order)) &&
        (record.ip_filter_mode.geo_filter == null || contains(["none", "location", "country"], record.ip_filter_mode.geo_filter))
      )
    ])
    error_message = "ip_filter_mode values are invalid. count: single|multi, order: none|weighted|rr, geo_filter: none|location|country."
  }

  # Validate A records have valid values
  validation {
    condition = alltrue([
      for record in var.records :
      record.type != "a" || (record.value.a != null && length(record.value.a) > 0)
    ])
    error_message = "A records must have at least one IP address in value.a."
  }

  # Validate AAAA records have valid values
  validation {
    condition = alltrue([
      for record in var.records :
      record.type != "aaaa" || (record.value.aaaa != null && length(record.value.aaaa) > 0)
    ])
    error_message = "AAAA records must have at least one IPv6 address in value.aaaa."
  }

  # Validate port ranges for A/AAAA records
  validation {
    condition = alltrue(flatten([
      for record in var.records : [
        for ip in coalesce(record.value.a, []) :
        ip.port == null || (ip.port >= 1 && ip.port <= 65535)
      ] if record.type == "a"
    ]))
    error_message = "Port must be between 1 and 65535 for A records."
  }

  validation {
    condition = alltrue(flatten([
      for record in var.records : [
        for ip in coalesce(record.value.aaaa, []) :
        ip.port == null || (ip.port >= 1 && ip.port <= 65535)
      ] if record.type == "aaaa"
    ]))
    error_message = "Port must be between 1 and 65535 for AAAA records."
  }

  # Validate weight ranges for A/AAAA records
  validation {
    condition = alltrue(flatten([
      for record in var.records : [
        for ip in coalesce(record.value.a, []) :
        ip.weight == null || (ip.weight >= 0 && ip.weight <= 1000)
      ] if record.type == "a"
    ]))
    error_message = "Weight must be between 0 and 1000 for A records."
  }

  validation {
    condition = alltrue(flatten([
      for record in var.records : [
        for ip in coalesce(record.value.aaaa, []) :
        ip.weight == null || (ip.weight >= 0 && ip.weight <= 1000)
      ] if record.type == "aaaa"
    ]))
    error_message = "Weight must be between 0 and 1000 for AAAA records."
  }

  # Validate CAA tag values
  validation {
    condition = alltrue([
      for record in var.records :
      record.type != "caa" || (
        record.value.caa != null &&
        contains(["issue", "issuewild", "iodef"], record.value.caa.tag)
      )
    ])
    error_message = "CAA record tag must be one of: issue, issuewild, iodef."
  }

  # Validate CNAME host_header values
  validation {
    condition = alltrue([
      for record in var.records :
      record.type != "cname" || (
        record.value.cname != null &&
        contains(["source", "dest"], record.value.cname.host_header)
      )
    ])
    error_message = "CNAME record host_header must be one of: source, dest."
  }

  # Validate ANAME host_header values
  validation {
    condition = alltrue([
      for record in var.records :
      record.type != "aname" || (
        record.value.aname != null &&
        contains(["source", "dest"], record.value.aname.host_header)
      )
    ])
    error_message = "ANAME record host_header must be one of: source, dest."
  }
}
