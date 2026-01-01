variable "domain" {
  description = "The domain name for the DNS zone"
  type        = string
}

variable "records" {
  description = "The list of DNS records"
  type = list(object({
    name           = string
    ttl            = number
    cloud          = bool
    upstream_https = string
    ip_filter_mode = object({
      count      = string
      order      = string
      geo_filter = string
    })
    type = string
    value = object({
      a = optional(list(object({
        ip      = string
        country = optional(string)
        port    = optional(number)
        weight  = optional(number)
      })))
      aaaa = optional(list(object({
        ip      = string
        country = optional(string)
        port    = optional(number)
        weight  = optional(number)
      })))
      aname = optional(object({
        host_header = string
        location    = string
        port        = optional(number)
      }))
      caa = optional(object({
        tag   = string
        value = string
      }))
      cname = optional(object({
        host        = string
        host_header = string
        port        = number
      }))
      dkim = optional(object({
        text = string
      }))
      mx = optional(object({
        priority = number
        host     = string
      }))
      ns = optional(object({
        host = string
      }))
      ptr = optional(object({
        domain = string
      }))
      spf = optional(object({
        text     = string
        port     = optional(number)
        priority = optional(number)
        weight   = optional(number)
      }))
      srv = optional(object({
        target   = string
        port     = optional(number)
        priority = optional(number)
        weight   = optional(number)
      }))
      tlsa = optional(object({
        certificate   = string
        matching_type = string
        selector      = string
        usage         = string
      }))
      txt = optional(object({
        text = string
      }))
    })
  }))

  validation {
    condition     = length(var.records) > 0
    error_message = "The records list must contain at least one record"
  }

}
