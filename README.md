# ArvanCloud CDN DNS Terraform Module

![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.5-623CE4?logo=terraform)
![Version](https://img.shields.io/github/v/release/terraform-r1c-modules/Terraform-R1C-DNS?logo=github&color=red&label=Version)
![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)

Reusable Terraform module that manages DNS records on an **existing** ArvanCloud CDN domain. It does not create zones, configure a provider, or own remote state.

- [ArvanCloud CDN DNS Terraform Module](#arvancloud-cdn-dns-terraform-module)
  - [Requirements](#requirements)
  - [Usage](#usage)
    - [Advanced example with all record types](#advanced-example-with-all-record-types)
  - [Examples](#examples)
  - [Inputs](#inputs)
    - [Record Object Structure](#record-object-structure)
    - [Handling Duplicate Record Names](#handling-duplicate-record-names)
    - [IP Filter Mode](#ip-filter-mode)
    - [Record Value Types](#record-value-types)
      - [A / AAAA Records](#a--aaaa-records)
      - [CNAME Record](#cname-record)
      - [ANAME Record](#aname-record)
      - [MX Record](#mx-record)
      - [TXT / SPF / DKIM Records](#txt--spf--dkim-records)
      - [CAA Record](#caa-record)
      - [SRV Record](#srv-record)
      - [NS Record](#ns-record)
      - [PTR Record](#ptr-record)
      - [TLSA Record](#tlsa-record)
  - [Outputs](#outputs)
  - [Notes](#notes)
  - [Development](#development)
  - [License](#license)

## Requirements

| Name                                                                                      | Version  |
| ----------------------------------------------------------------------------------------- | -------- |
| [Terraform](https://developer.hashicorp.com/terraform)                                    | >= 1.5   |
| [Arvancloud Provider](https://git.arvancloud.ir/arvancloud/terraform-provider-arvancloud) | >= 0.2.2 |

The ArvanCloud provider is **not** on `registry.terraform.io`. Consumers must declare:

```hcl
terraform {
  required_providers {
    arvancloud = {
      source  = "terraform.arvancloud.ir/arvancloud/arvancloud"
      version = ">= 0.2.2"
    }
  }
}

provider "arvancloud" {
  api_key = var.arvancloud_api_key
}
```

## Usage

Pin a release tag rather than `main`. The domain must already exist in ArvanCloud CDN.

```hcl
module "cdn_dns" {
  source = "git::https://github.com/terraform-r1c-modules/Terraform-R1C-DNS.git?ref=v1.0.1"

  domain = "example.ir"

  records = [
    {
      name = "www"
      type = "a"
      key  = "www-a"
      value = {
        a = [{ ip = "1.2.3.4" }]
      }
    },
    {
      name = "verification"
      type = "txt"
      key  = "site-verification"
      value = {
        txt = { text = "verify-domain-12345" }
      }
    }
  ]
}
```

### Advanced example with all record types

```hcl
module "cdn_dns" {
  source = "git::https://github.com/terraform-r1c-modules/Terraform-R1C-DNS.git?ref=v1.0.1"

  domain = "example.ir"

  records = [
    # A record with multiple IPs, load balancing, and custom settings
    {
      name           = "api"
      type           = "a"
      key            = "api-a"
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
      key  = "ipv6-aaaa"
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
      key   = "cdn-cname"
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
      key  = "apex-aname"
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
      key  = "mail-mx"
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
      key  = "apex-spf-txt"
      value = {
        txt = { text = "v=spf1 include:_spf.example.com ~all" }
      }
    },

    # SPF record
    {
      name = "@"
      type = "spf"
      key  = "apex-spf"
      value = {
        spf = { text = "v=spf1 include:_spf.example.com ~all" }
      }
    },

    # DKIM record
    {
      name = "selector._domainkey"
      type = "dkim"
      key  = "selector-dkim"
      value = {
        dkim = { text = "v=DKIM1; k=rsa; p=MIGfMA0GCSqGS..." }
      }
    },

    # CAA record
    {
      name = "@"
      type = "caa"
      key  = "apex-caa-issue"
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
      key  = "subdomain-ns1"
      value = {
        ns = { host = "ns1.example.com." }
      }
    },

    # SRV record
    {
      name = "_sip._tcp"
      type = "srv"
      key  = "sip-srv"
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
      key  = "www-tlsa"
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
      key  = "ptr-1"
      value = {
        ptr = { domain = "host.example.ir" }
      }
    }
  ]
}
```

## Examples

| Directory                              | Description                                                 |
| -------------------------------------- | ----------------------------------------------------------- |
| [examples/basic](examples/basic)       | Minimal consumer: A, MX, and TXT records with explicit keys |
| [examples/advanced](examples/advanced) | All record types, `ip_filter_mode`, and custom keys         |
| [wrappers](wrappers)                   | `for_each` wrapper for Terragrunt-style maps of domains     |

## Inputs

| Name      | Description                                   | Type           | Default | Required |
| --------- | --------------------------------------------- | -------------- | ------- | :------: |
| `domain`  | Existing ArvanCloud CDN domain (name or UUID) | `string`       | n/a     |   Yes    |
| `records` | List of DNS records to create                 | `list(object)` | `[]`    |    No    |

### Record Object Structure

| Field            | Description                                                                      | Type     | Default                                          | Required |
| ---------------- | -------------------------------------------------------------------------------- | -------- | ------------------------------------------------ | :------: |
| `name`           | The name of the record                                                           | `string` | n/a                                              |   Yes    |
| `type`           | Record type (a, aaaa, aname, caa, cname, dkim, mx, ns, ptr, spf, srv, tlsa, txt) | `string` | n/a                                              |   Yes    |
| `key`            | Unique identifier for duplicate name records (auto-generated if not provided)    | `string` | `{name}_{type}_{index}`                          |    No    |
| `ttl`            | Time to live in seconds (60-86400)                                               | `number` | `120`                                            |    No    |
| `cloud`          | Whether record is proxied through ArvanCloud CDN                                 | `bool`   | `true` for A/AAAA/CNAME/ANAME, `false` otherwise |    No    |
| `upstream_https` | HTTPS config: default, auto, http, https                                         | `string` | `"default"`                                      |    No    |
| `ip_filter_mode` | IP filtering configuration                                                       | `object` | See below                                        |    No    |
| `value`          | Record value object (varies by type)                                             | `object` | n/a                                              |   Yes    |

> [!WARNING]
> Always set an explicit `key` on each record (especially duplicates). Auto keys are `{name}_{type}_{index}`. Inserting or reordering the list without custom keys recreates resources.

### Handling Duplicate Record Names

When you have multiple records with the same name (e.g., multiple MX or TXT records at `@`), the module generates unique keys per type. Prefer custom keys:

```hcl
records = [
  {
    name = "@"
    type = "mx"
    key  = "mx-primary"
    value = { mx = { host = "mx1.example.com.", priority = 10 } }
  },
  {
    name = "@"
    type = "mx"
    key  = "mx-secondary"
    value = { mx = { host = "mx2.example.com.", priority = 20 } }
  },
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

Keys only need to be unique **within the same record type**. An A record and a TXT record may share a key.

### IP Filter Mode

| Field        | Description     | Values                        | Default  |
| ------------ | --------------- | ----------------------------- | -------- |
| `count`      | Count mode      | `single`, `multi`             | `single` |
| `order`      | Order mode      | `none`, `weighted`, `rr`      | `none`   |
| `geo_filter` | Geo filter mode | `none`, `location`, `country` | `none`   |

### Record Value Types

#### A / AAAA Records

```hcl
value = {
  a = [  # or aaaa for IPv6
    {
      ip      = "1.2.3.4"        # Required, valid IPv4 / IPv6
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
    host        = "target.example.com."  # Required, FQDN ending with .
    host_header = "source"               # Required: source or dest
    port        = 443                    # Optional (1-65535)
  }
}
```

#### ANAME Record

```hcl
value = {
  aname = {
    location    = "origin.example.com."  # Required, FQDN ending with .
    host_header = "dest"                 # Required: source or dest
    port        = 443                    # Optional (1-65535)
  }
}
```

#### MX Record

```hcl
value = {
  mx = {
    host     = "mail.example.com."  # Required, FQDN ending with .
    priority = 10                   # Required (0-65535)
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
    target   = "service.example.com."  # Required, FQDN ending with .
    port     = 5060                    # Optional (1-65535)
    priority = 10                      # Optional (0-65535)
    weight   = 100                     # Optional (0-65535)
  }
}
```

#### NS Record

```hcl
value = {
  ns = { host = "ns1.example.com." }  # FQDN ending with .
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
    usage         = "3"           # Required: 0-3
    selector      = "1"           # Required: 0-1
    matching_type = "1"           # Required: 0-2
    certificate   = "abc123..."   # Required
  }
}
```

## Outputs

| Name             | Description                              |
| ---------------- | ---------------------------------------- |
| `domain`         | Domain these records belong to           |
| `a_records`      | A record details (id, name, type)        |
| `aaaa_records`   | AAAA record details                      |
| `aname_records`  | ANAME record details                     |
| `caa_records`    | CAA record details                       |
| `cname_records`  | CNAME record details                     |
| `dkim_records`   | DKIM record details                      |
| `mx_records`     | MX record details                        |
| `ns_records`     | NS record details                        |
| `ptr_records`    | PTR record details                       |
| `spf_records`    | SPF record details                       |
| `srv_records`    | SRV record details                       |
| `tlsa_records`   | TLSA record details                      |
| `txt_records`    | TXT record details                       |
| `all_record_ids` | Map of all record IDs organized by type  |
| `record_count`   | Count of records by type including total |

## Notes

1. **Existing domain**: This module only manages records. Create the CDN domain (and provider/backend) in the consuming root module.
2. **FQDN format**: CNAME `host`, ANAME `location`, MX/NS `host`, and SRV `target` must end with a dot (e.g. `example.com.`).
3. **Cloud-enabled records**: `cloud = true` proxies the record through ArvanCloud CDN. That default applies to A, AAAA, CNAME, and ANAME only. Leave mail and security records (MX, TXT, SPF, DKIM, CAA, TLSA, SRV, NS, PTR) unproxied.
4. **Load balancing**: For A and AAAA records with multiple IPs, use `ip_filter_mode` to configure load balancing.
5. **Record names**: Use `@` for apex/root domain records.
6. **Record types** are lowercase (`a`, not `A`).
7. **Version pinning**: Pin the module `?ref=` to a release tag in production.

## Development

Local checks are the quality gate (there is no CI pipeline):

```bash
make check          # fmt-check, validate, lint
make pre-commit     # all pre-commit hooks
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for setup and [examples/basic/README.md](examples/basic/README.md) for apply/destroy against a test domain.

## License

Apache 2.0 Licensed. See [LICENSE](LICENSE) for full details.
