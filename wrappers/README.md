# Wrappers

Wrapper around this module for Terragrunt (or other tools) that cannot use native `for_each` on a module.

It does not add behavior. Each key in `items` becomes one module instance; values in `items` override `defaults`.

## Usage with Terraform

```hcl
module "dns" {
  source = "git::https://github.com/terraform-r1c-modules/Terraform-R1C-DNS.git//wrappers?ref=v1.0.1"

  defaults = {
    records = []
  }

  items = {
    example = {
      domain = "example.ir"
      records = [
        {
          name = "www"
          type = "a"
          key  = "www-a"
          value = {
            a = [{ ip = "1.2.3.4" }]
          }
        }
      ]
    }
  }
}
```

## Usage with Terragrunt

```hcl
terraform {
  source = "git::https://github.com/terraform-r1c-modules/Terraform-R1C-DNS.git//wrappers?ref=v1.0.1"
}

inputs = {
  defaults = {
    records = []
  }

  items = {
    example = {
      domain = "example.ir"
      records = [
        {
          name = "www"
          type = "a"
          key  = "www-a"
          value = {
            a = [{ ip = "1.2.3.4" }]
          }
        }
      ]
    }
  }
}
```
