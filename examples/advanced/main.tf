# =============================================================================
# Advanced Example - Full DNS Configuration
# =============================================================================
# This example demonstrates advanced usage with all record types, load balancing,
# multiple origins, and comprehensive email configuration.

terraform {
  required_version = ">= 1.5"

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

# =============================================================================
# Local Variables for Origin Servers
# =============================================================================

locals {
  origins = {
    primary = {
      v4 = "1.1.1.1"
      v6 = "2001:db8::1"
    }
    secondary = {
      v4 = "1.1.1.2"
      v6 = "2001:db8::2"
    }
    monitoring = {
      v4 = "2.2.2.1"
    }
  }
}

# =============================================================================
# DNS Module
# =============================================================================

module "dns" {
  source = "../../"

  domain = var.domain

  records = [
    # =========================================================================
    # A Records with Load Balancing
    # =========================================================================
    {
      name           = "@"
      type           = "a"
      ttl            = 300
      cloud          = true
      upstream_https = "https"
      ip_filter_mode = {
        count      = "multi"
        order      = "weighted"
        geo_filter = "none"
      }
      value = {
        a = [
          { ip = local.origins.primary.v4, port = 443, weight = 100 },
          { ip = local.origins.secondary.v4, port = 443, weight = 50 }
        ]
      }
    },
    {
      name  = "api"
      type  = "a"
      ttl   = 60
      cloud = true
      ip_filter_mode = {
        count      = "single"
        order      = "rr"
        geo_filter = "none"
      }
      value = {
        a = [
          { ip = local.origins.primary.v4, port = 443 },
          { ip = local.origins.secondary.v4, port = 443 }
        ]
      }
    },
    {
      name  = "grafana"
      type  = "a"
      cloud = true
      value = {
        a = [{ ip = local.origins.monitoring.v4, port = 443 }]
      }
    },
    {
      name  = "prometheus"
      type  = "a"
      cloud = true
      value = {
        a = [{ ip = local.origins.monitoring.v4, port = 443 }]
      }
    },

    # =========================================================================
    # AAAA Records (IPv6)
    # =========================================================================
    {
      name  = "ipv6"
      type  = "aaaa"
      cloud = true
      value = {
        aaaa = [
          { ip = local.origins.primary.v6 },
          { ip = local.origins.secondary.v6, weight = 50 }
        ]
      }
    },

    # =========================================================================
    # CNAME Records
    # =========================================================================
    {
      name  = "www"
      type  = "cname"
      cloud = true
      value = {
        cname = { host = "${var.domain}.", host_header = "source" }
      }
    },
    {
      name  = "cdn"
      type  = "cname"
      cloud = true
      value = {
        cname = { host = "cdn.provider.com.", host_header = "source", port = 443 }
      }
    },
    {
      name  = "docs"
      type  = "cname"
      cloud = true
      value = {
        cname = { host = "organization.github.io.", host_header = "source" }
      }
    },
    {
      name  = "status"
      type  = "cname"
      cloud = false
      value = {
        cname = { host = "status.example.com.", host_header = "source" }
      }
    },

    # =========================================================================
    # ANAME Record (Apex Alias)
    # =========================================================================
    {
      name  = "alias"
      type  = "aname"
      cloud = true
      value = {
        aname = {
          location    = "origin.example.com."
          host_header = "dest"
          port        = 443
        }
      }
    },

    # =========================================================================
    # MX Records (Mail - Multiple Priorities)
    # =========================================================================
    {
      name  = "@"
      type  = "mx"
      key   = "mx-primary"
      cloud = false
      value = {
        mx = { host = "mx1.mail.com.", priority = 10 }
      }
    },
    {
      name  = "@"
      type  = "mx"
      key   = "mx-secondary"
      cloud = false
      value = {
        mx = { host = "mx2.mail.com.", priority = 20 }
      }
    },
    {
      name  = "@"
      type  = "mx"
      key   = "mx-backup"
      cloud = false
      value = {
        mx = { host = "mx-backup.mail.com.", priority = 50 }
      }
    },

    # =========================================================================
    # TXT Records (Email Authentication)
    # =========================================================================
    # SPF Record
    {
      name  = "@"
      type  = "txt"
      key   = "spf"
      cloud = false
      value = {
        txt = { text = "v=spf1 include:_spf.mail.com include:sendgrid.net ~all" }
      }
    },
    # DKIM Record
    {
      name  = "mail._domainkey"
      type  = "txt"
      cloud = false
      value = {
        txt = { text = "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC..." }
      }
    },
    # DMARC Record
    {
      name  = "_dmarc"
      type  = "txt"
      cloud = false
      value = {
        txt = { text = "v=DMARC1; p=quarantine; rua=mailto:dmarc@${var.domain}; ruf=mailto:dmarc@${var.domain}; sp=reject; adkim=s; aspf=s" }
      }
    },
    # Domain Verifications
    {
      name  = "@"
      type  = "txt"
      key   = "google-verification"
      cloud = false
      value = {
        txt = { text = "google-site-verification=abc123xyz" }
      }
    },
    {
      name  = "@"
      type  = "txt"
      key   = "github-verification"
      cloud = false
      value = {
        txt = { text = "github-organization-verification=abc123" }
      }
    },

    # =========================================================================
    # SPF Record (Dedicated Type)
    # =========================================================================
    {
      name  = "mail"
      type  = "spf"
      cloud = false
      value = {
        spf = { text = "v=spf1 a mx ~all" }
      }
    },

    # =========================================================================
    # DKIM Record (Dedicated Type)
    # =========================================================================
    {
      name  = "selector._domainkey"
      type  = "dkim"
      cloud = false
      value = {
        dkim = { text = "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA..." }
      }
    },

    # =========================================================================
    # CAA Records (Certificate Authority Authorization)
    # =========================================================================
    {
      name  = "@"
      type  = "caa"
      key   = "caa-issue"
      cloud = false
      value = {
        caa = { tag = "issue", value = "letsencrypt.org" }
      }
    },
    {
      name  = "@"
      type  = "caa"
      key   = "caa-issuewild"
      cloud = false
      value = {
        caa = { tag = "issuewild", value = "letsencrypt.org" }
      }
    },
    {
      name  = "@"
      type  = "caa"
      key   = "caa-iodef"
      cloud = false
      value = {
        caa = { tag = "iodef", value = "mailto:security@${var.domain}" }
      }
    },

    # =========================================================================
    # NS Records (Subdomain Delegation)
    # =========================================================================
    {
      name  = "subdomain"
      type  = "ns"
      key   = "ns1"
      cloud = false
      value = {
        ns = { host = "ns1.subdomain-provider.com." }
      }
    },
    {
      name  = "subdomain"
      type  = "ns"
      key   = "ns2"
      cloud = false
      value = {
        ns = { host = "ns2.subdomain-provider.com." }
      }
    },

    # =========================================================================
    # SRV Records (Service Discovery)
    # =========================================================================
    {
      name  = "_sip._tcp"
      type  = "srv"
      cloud = false
      value = {
        srv = {
          target   = "sip.${var.domain}."
          port     = 5060
          priority = 10
          weight   = 100
        }
      }
    },
    {
      name  = "_xmpp-server._tcp"
      type  = "srv"
      cloud = false
      value = {
        srv = {
          target   = "xmpp.${var.domain}."
          port     = 5269
          priority = 10
          weight   = 100
        }
      }
    },
    {
      name  = "_autodiscover._tcp"
      type  = "srv"
      cloud = false
      value = {
        srv = {
          target   = "autodiscover.mail.com."
          port     = 443
          priority = 0
          weight   = 0
        }
      }
    },

    # =========================================================================
    # TLSA Records (TLS Certificate Pinning)
    # =========================================================================
    {
      name  = "_443._tcp.www"
      type  = "tlsa"
      cloud = false
      value = {
        tlsa = {
          usage         = "3"
          selector      = "1"
          matching_type = "1"
          certificate   = "abc123def456..."
        }
      }
    },

    # =========================================================================
    # PTR Record (Reverse DNS)
    # =========================================================================
    {
      name  = "1.1.1.1.in-addr.arpa"
      type  = "ptr"
      cloud = false
      value = {
        ptr = { domain = "mail.${var.domain}" }
      }
    }
  ]
}
