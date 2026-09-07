# =============================================================================
# Domain Configuration
# =============================================================================

variable "domain" {
  description = "Existing ArvanCloud CDN domain (name or UUID) whose DNS records this module manages."
  type        = string
  nullable    = false

  validation {
    condition     = length(trimspace(var.domain)) > 0
    error_message = "Domain name cannot be empty."
  }
}

# =============================================================================
# DNS Records Configuration
# =============================================================================

variable "records" {
  description = <<-EOT
    List of DNS records to create on the existing domain. Each record requires
    name, type, and a type-specific value object. Optional fields use the
    defaults documented in the README.

    Set an explicit `key` on every record (especially duplicates). Auto keys
    are `{name}_{type}_{index}` — inserting or reordering the list without
    custom keys recreates resources.

    Supported record types (lowercase):
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

  default  = []
  nullable = false

  validation {
    condition = alltrue([
      for record in var.records :
      contains(["a", "aaaa", "aname", "caa", "cname", "dkim", "mx", "ns", "ptr", "spf", "srv", "tlsa", "txt"], record.type)
    ])
    error_message = "Record type must be one of: a, aaaa, aname, caa, cname, dkim, mx, ns, ptr, spf, srv, tlsa, txt (lowercase)."
  }

  validation {
    condition = alltrue([
      for record in var.records :
      length(trimspace(record.name)) > 0
    ])
    error_message = "Record name cannot be empty."
  }

  validation {
    condition = alltrue([
      for record in var.records :
      record.key == null || length(trimspace(record.key)) > 0
    ])
    error_message = "Record key, when set, cannot be empty."
  }

  validation {
    condition = alltrue([
      for t in distinct([for r in var.records : r.type]) :
      length(distinct([
        for idx, r in var.records : coalesce(r.key, "${r.name}_${r.type}_${idx}") if r.type == t
        ])) == length([
        for idx, r in var.records : coalesce(r.key, "${r.name}_${r.type}_${idx}") if r.type == t
      ])
    ])
    error_message = "Record keys must be unique per type. Set an explicit unique `key` on records that share a name, and avoid colliding with auto-generated `{name}_{type}_{index}` keys."
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

  # ---------------------------------------------------------------------------
  # A / AAAA
  # ---------------------------------------------------------------------------

  validation {
    condition = alltrue([
      for record in var.records :
      record.type != "a" || (record.value.a != null && length(record.value.a) > 0)
    ])
    error_message = "A records must have at least one IP address in value.a."
  }

  validation {
    condition = alltrue([
      for record in var.records :
      record.type != "aaaa" || (record.value.aaaa != null && length(record.value.aaaa) > 0)
    ])
    error_message = "AAAA records must have at least one IPv6 address in value.aaaa."
  }

  validation {
    condition = alltrue(flatten([
      for record in var.records : [
        for ip in coalesce(record.value.a, []) :
        can(cidrhost("${ip.ip}/32", 0))
      ] if record.type == "a"
    ]))
    error_message = "A record values must be valid IPv4 addresses."
  }

  validation {
    condition = alltrue(flatten([
      for record in var.records : [
        for ip in coalesce(record.value.aaaa, []) :
        can(cidrhost("${ip.ip}/128", 0))
      ] if record.type == "aaaa"
    ]))
    error_message = "AAAA record values must be valid IPv6 addresses."
  }

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

  # ---------------------------------------------------------------------------
  # CNAME / ANAME
  # ---------------------------------------------------------------------------

  validation {
    condition = alltrue([
      for record in var.records :
      record.type != "cname" || (
        record.value.cname != null &&
        endswith(record.value.cname.host, ".") &&
        contains(["source", "dest"], record.value.cname.host_header) &&
        (record.value.cname.port == null || (record.value.cname.port >= 1 && record.value.cname.port <= 65535))
      )
    ])
    error_message = "CNAME records require value.cname with a FQDN host ending in '.', host_header of source|dest, and an optional port between 1 and 65535."
  }

  validation {
    condition = alltrue([
      for record in var.records :
      record.type != "aname" || (
        record.value.aname != null &&
        endswith(record.value.aname.location, ".") &&
        contains(["source", "dest"], record.value.aname.host_header) &&
        (record.value.aname.port == null || (record.value.aname.port >= 1 && record.value.aname.port <= 65535))
      )
    ])
    error_message = "ANAME records require value.aname with a FQDN location ending in '.', host_header of source|dest, and an optional port between 1 and 65535."
  }

  # ---------------------------------------------------------------------------
  # CAA / DKIM / SPF / TXT
  # ---------------------------------------------------------------------------

  validation {
    condition = alltrue([
      for record in var.records :
      record.type != "caa" || (
        record.value.caa != null &&
        contains(["issue", "issuewild", "iodef"], record.value.caa.tag) &&
        length(trimspace(record.value.caa.value)) > 0
      )
    ])
    error_message = "CAA records require value.caa with tag issue|issuewild|iodef and a non-empty value."
  }

  validation {
    condition = alltrue([
      for record in var.records :
      record.type != "dkim" || (
        record.value.dkim != null && length(trimspace(record.value.dkim.text)) > 0
      )
    ])
    error_message = "DKIM records require a non-empty value.dkim.text."
  }

  validation {
    condition = alltrue([
      for record in var.records :
      record.type != "spf" || (
        record.value.spf != null && length(trimspace(record.value.spf.text)) > 0
      )
    ])
    error_message = "SPF records require a non-empty value.spf.text."
  }

  validation {
    condition = alltrue([
      for record in var.records :
      record.type != "txt" || (
        record.value.txt != null && length(trimspace(record.value.txt.text)) > 0
      )
    ])
    error_message = "TXT records require a non-empty value.txt.text."
  }

  # ---------------------------------------------------------------------------
  # MX / NS / PTR / SRV / TLSA
  # ---------------------------------------------------------------------------

  validation {
    condition = alltrue([
      for record in var.records :
      record.type != "mx" || (
        record.value.mx != null &&
        endswith(record.value.mx.host, ".") &&
        record.value.mx.priority >= 0 &&
        record.value.mx.priority <= 65535
      )
    ])
    error_message = "MX records require value.mx with a FQDN host ending in '.' and priority between 0 and 65535."
  }

  validation {
    condition = alltrue([
      for record in var.records :
      record.type != "ns" || (
        record.value.ns != null && endswith(record.value.ns.host, ".")
      )
    ])
    error_message = "NS records require value.ns with a FQDN host ending in '.'."
  }

  validation {
    condition = alltrue([
      for record in var.records :
      record.type != "ptr" || (
        record.value.ptr != null && length(trimspace(record.value.ptr.domain)) > 0
      )
    ])
    error_message = "PTR records require a non-empty value.ptr.domain."
  }

  validation {
    condition = alltrue([
      for record in var.records :
      record.type != "srv" || (
        record.value.srv != null &&
        endswith(record.value.srv.target, ".") &&
        (record.value.srv.port == null || (record.value.srv.port >= 1 && record.value.srv.port <= 65535)) &&
        (record.value.srv.priority == null || (record.value.srv.priority >= 0 && record.value.srv.priority <= 65535)) &&
        (record.value.srv.weight == null || (record.value.srv.weight >= 0 && record.value.srv.weight <= 65535))
      )
    ])
    error_message = "SRV records require value.srv with a FQDN target ending in '.', optional port 1-65535, and optional priority/weight 0-65535."
  }

  validation {
    condition = alltrue([
      for record in var.records :
      record.type != "tlsa" || (
        record.value.tlsa != null &&
        contains(["0", "1", "2", "3"], record.value.tlsa.usage) &&
        contains(["0", "1"], record.value.tlsa.selector) &&
        contains(["0", "1", "2"], record.value.tlsa.matching_type) &&
        length(trimspace(record.value.tlsa.certificate)) > 0
      )
    ])
    error_message = "TLSA records require value.tlsa with usage 0-3, selector 0-1, matching_type 0-2, and a non-empty certificate."
  }
}
