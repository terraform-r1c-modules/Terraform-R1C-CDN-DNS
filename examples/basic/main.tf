# =============================================================================
# Basic Example - Simple DNS Records
# =============================================================================
# This example demonstrates basic usage of the DNS module with common record types.

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
# DNS Module
# =============================================================================

module "dns" {
  source = "../../"

  domain = var.domain

  records = [
    # A record for root domain
    {
      name  = "@"
      type  = "a"
      cloud = true
      value = {
        a = [{ ip = "1.2.3.4" }]
      }
    },

    # A record for www subdomain
    {
      name  = "www"
      type  = "a"
      cloud = true
      value = {
        a = [{ ip = "1.2.3.4" }]
      }
    },

    # A record for API subdomain
    {
      name  = "api"
      type  = "a"
      cloud = true
      value = {
        a = [{ ip = "1.2.3.5" }]
      }
    },

    # MX record for email
    {
      name  = "@"
      type  = "mx"
      cloud = false
      value = {
        mx = { host = "mail.example.com.", priority = 10 }
      }
    },

    # TXT record for SPF
    {
      name  = "@"
      type  = "txt"
      key   = "spf"
      cloud = false
      value = {
        txt = { text = "v=spf1 mx ~all" }
      }
    },

    # TXT record for domain verification
    {
      name  = "@"
      type  = "txt"
      key   = "verification"
      cloud = false
      value = {
        txt = { text = "verify-domain-12345" }
      }
    }
  ]
}
