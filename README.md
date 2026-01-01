# Terraform ArvanCloud DNS Module

Terraform module to manage ArvanCloud CDN DNS records with support for all record types.

## Requirements

| Name       | Version  |
| ---------- | -------- |
| terraform  | >= 1.5   |
| arvancloud | >= 0.2.2 |

## Usage

### Basic Example

```hcl
module "dns" {
  source = "path/to/module"

  domain = "example.ir"

  records = [
    # Simple A record
    {
      name = "www"
      type = "a"
      value = {
        a = [{ ip = "1.2.3.4" }]
      }
    },

    # TXT record for verification
    {
      name = "verification"
      type = "txt"
      value = {
        txt = { text = "verify-domain-12345" }
      }
    }
  ]
}
```

### Advanced Example with All Record Types

```hcl
module "dns" {
  source = "path/to/module"

  domain = "example.ir"

  records = [
    # A record with multiple IPs, load balancing, and custom settings
    {
      name           = "api"
      type           = "a"
      ttl            = 300
      cloud          = true
      upstream_https = "https"
      ip_filter_mode = {
        count      = "multi"
        order      = "weighted"
        geo_filter = "country"
      }
      value = {
        a = [
          { ip = "1.1.1.1", port = 443, weight = 100 },
          { ip = "1.1.1.2", port = 443, weight = 50, country = "IR" }
        ]
      }
    },

    # AAAA record (IPv6)
    {
      name = "ipv6"
      type = "aaaa"
      value = {
        aaaa = [
          { ip = "2001:db8::1" },
          { ip = "2001:db8::2", weight = 50 }
        ]
      }
    },

    # CNAME record
    {
      name  = "cdn"
      type  = "cname"
      cloud = true
      value = {
        cname = {
          host        = "cdn.provider.com."
          host_header = "source"
          port        = 443
        }
      }
    },

    # ANAME record (apex alias)
    {
      name = "@"
      type = "aname"
      value = {
        aname = {
          location    = "origin.example.com."
          host_header = "dest"
        }
      }
    },

    # MX records for email
    {
      name = "mail"
      type = "mx"
      value = {
        mx = {
          host     = "mail.example.ir."
          priority = 10
        }
      }
    },

    # TXT record
    {
      name = "@"
      type = "txt"
      value = {
        txt = { text = "v=spf1 include:_spf.example.com ~all" }
      }
    },

    # SPF record
    {
      name = "@"
      type = "spf"
      value = {
        spf = { text = "v=spf1 include:_spf.example.com ~all" }
      }
    },

    # DKIM record
    {
      name = "selector._domainkey"
      type = "dkim"
      value = {
        dkim = { text = "v=DKIM1; k=rsa; p=MIGfMA0GCSqGS..." }
      }
    },

    # CAA record
    {
      name = "@"
      type = "caa"
      value = {
        caa = {
          tag   = "issue"
          value = "letsencrypt.org"
        }
      }
    },

    # NS record
    {
      name = "subdomain"
      type = "ns"
      value = {
        ns = { host = "ns1.example.com." }
      }
    },

    # SRV record
    {
      name = "_sip._tcp"
      type = "srv"
      value = {
        srv = {
          target   = "sip.example.ir."
          port     = 5060
          priority = 10
          weight   = 100
        }
      }
    },

    # TLSA record
    {
      name = "_443._tcp.www"
      type = "tlsa"
      value = {
        tlsa = {
          usage         = "3"
          selector      = "1"
          matching_type = "1"
          certificate   = "abc123..."
        }
      }
    },

    # PTR record
    {
      name = "4.3.2.1.in-addr.arpa"
      type = "ptr"
      value = {
        ptr = { domain = "host.example.ir" }
      }
    }
  ]
}
```

## Inputs

| Name    | Description                                     | Type           | Default | Required |
| ------- | ----------------------------------------------- | -------------- | ------- | :------: |
| domain  | The domain name (UUID or name) for the DNS zone | `string`       | n/a     |   yes    |
| records | List of DNS records to create                   | `list(object)` | `[]`    |    no    |

### Record Object Structure

| Field          | Description                                                                      | Type     | Default                                          | Required |
| -------------- | -------------------------------------------------------------------------------- | -------- | ------------------------------------------------ | :------: |
| name           | The name of the record                                                           | `string` | n/a                                              |   yes    |
| type           | Record type (a, aaaa, aname, caa, cname, dkim, mx, ns, ptr, spf, srv, tlsa, txt) | `string` | n/a                                              |   yes    |
| key            | Unique identifier for duplicate name records (auto-generated if not provided)    | `string` | `{name}_{type}_{index}`                          |    no    |
| ttl            | Time to live in seconds (60-86400)                                               | `number` | `120`                                            |    no    |
| cloud          | Whether record is managed by ArvanCloud CDN                                      | `bool`   | `true` for A/AAAA/CNAME/ANAME, `false` otherwise |    no    |
| upstream_https | HTTPS config: default, auto, http, https                                         | `string` | `"default"`                                      |    no    |
| ip_filter_mode | IP filtering configuration                                                       | `object` | See below                                        |    no    |
| value          | Record value object (varies by type)                                             | `object` | n/a                                              |   yes    |

### Handling Duplicate Record Names

When you have multiple records with the same name (e.g., multiple MX or TXT records at `@`), the module automatically generates unique keys. You can also provide custom keys using the `key` field:

```hcl
records = [
  # Multiple MX records with same name - auto-generated keys
  {
    name = "@"
    type = "mx"
    value = { mx = { host = "mx1.example.com.", priority = 10 } }
  },
  {
    name = "@"
    type = "mx"
    value = { mx = { host = "mx2.example.com.", priority = 20 } }
  },

  # Multiple TXT records with custom keys for better identification
  {
    name = "@"
    type = "txt"
    key  = "spf-record"
    value = { txt = { text = "v=spf1 include:example.com ~all" } }
  },
  {
    name = "@"
    type = "txt"
    key  = "google-verification"
    value = { txt = { text = "google-site-verification=abc123" } }
  }
]
```

### IP Filter Mode

| Field      | Description     | Values                        | Default  |
| ---------- | --------------- | ----------------------------- | -------- |
| count      | Count mode      | `single`, `multi`             | `single` |
| order      | Order mode      | `none`, `weighted`, `rr`      | `none`   |
| geo_filter | Geo filter mode | `none`, `location`, `country` | `none`   |

### Record Value Types

#### A / AAAA Records

```hcl
value = {
  a = [  # or aaaa for IPv6
    {
      ip      = "1.2.3.4"        # Required
      port    = 443              # Optional (1-65535)
      weight  = 100              # Optional (0-1000)
      country = "IR"             # Optional
    }
  ]
}
```

#### CNAME Record

```hcl
value = {
  cname = {
    host        = "target.example.com."  # Required, FQDN format
    host_header = "source"               # Required: source or dest
    port        = 443                    # Optional
  }
}
```

#### ANAME Record

```hcl
value = {
  aname = {
    location    = "origin.example.com."  # Required, FQDN format
    host_header = "dest"                 # Required: source or dest
    port        = 443                    # Optional
  }
}
```

#### MX Record

```hcl
value = {
  mx = {
    host     = "mail.example.com."  # Required, FQDN format
    priority = 10                   # Required
  }
}
```

#### TXT / SPF / DKIM Records

```hcl
value = {
  txt = { text = "your text content" }  # or spf, dkim
}
```

#### CAA Record

```hcl
value = {
  caa = {
    tag   = "issue"            # Required: issue, issuewild, iodef
    value = "letsencrypt.org"  # Required
  }
}
```

#### SRV Record

```hcl
value = {
  srv = {
    target   = "service.example.com."  # Required, FQDN format
    port     = 5060                    # Optional
    priority = 10                      # Optional
    weight   = 100                     # Optional
  }
}
```

#### NS Record

```hcl
value = {
  ns = { host = "ns1.example.com." }  # FQDN format
}
```

#### PTR Record

```hcl
value = {
  ptr = { domain = "host.example.com" }
}
```

#### TLSA Record

```hcl
value = {
  tlsa = {
    usage         = "3"           # Required
    selector      = "1"           # Required
    matching_type = "1"           # Required
    certificate   = "abc123..."   # Required
  }
}
```

## Outputs

| Name           | Description                              |
| -------------- | ---------------------------------------- |
| a_records      | A record details (id, name, type)        |
| aaaa_records   | AAAA record details                      |
| aname_records  | ANAME record details                     |
| caa_records    | CAA record details                       |
| cname_records  | CNAME record details                     |
| dkim_records   | DKIM record details                      |
| mx_records     | MX record details                        |
| ns_records     | NS record details                        |
| ptr_records    | PTR record details                       |
| spf_records    | SPF record details                       |
| srv_records    | SRV record details                       |
| tlsa_records   | TLSA record details                      |
| txt_records    | TXT record details                       |
| all_record_ids | Map of all record IDs organized by type  |
| record_count   | Count of records by type including total |

## Notes

1. **FQDN Format**: For CNAME, ANAME, MX, NS, and SRV records, hostnames must end with a dot (e.g., `example.com.`)
2. **Cloud-enabled Records**: When `cloud = true`, the record is proxied through ArvanCloud's CDN. This is typically used for A, AAAA, CNAME, and ANAME records.
3. **Load Balancing**: For A and AAAA records with multiple IPs, use `ip_filter_mode` to configure load balancing behavior.
4. **Record Names**: Use `@` for apex/root domain records.

## License

Apache 2.0 Licensed. See [LICENSE](LICENSE) for full details
