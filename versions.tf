terraform {
  required_version = ">= 1.11"

  required_providers {
    arvancloud = {
      source  = "terraform.arvancloud.ir/arvancloud/arvancloud"
      version = "0.2.2"
    }

  }
}
