# Project Guidelines

Reusable Terraform module that manages DNS records on an **existing** ArvanCloud CDN domain. It does not create zones, configure a provider, or own remote state.

Usage, record schemas, and I/O tables: [README.md](README.md).
Dev setup, style, and PR process: [CONTRIBUTING.md](CONTRIBUTING.md).

## Architecture

- Flat root module: `main.tf` (resources), `variables.tf` (contract), `outputs.tf`, `versions.tf`. No `modules/` tree.
- Consumers pass `domain` plus a HCL `records` list. Records stay in HCL — do not introduce YAML inventories.
- `main.tf` indexes records, splits them by `type` into locals, then creates one `arvancloud_cdn_domain_dns_record` `for_each` block per type.
- Root declares `required_providers` only. Put `provider "arvancloud"` and backends in **consumer** roots (`examples/*`), never in the module root.
- Provider source is `terraform.arvancloud.ir/arvancloud/arvancloud` (not `registry.terraform.io`).
- `wrappers/` is a Terragrunt-style `for_each` wrapper around this module.

## Build and Test

There is no GitHub Actions / GitLab CI pipeline. Local checks are the gate:

```bash
make check              # fmt-check + validate + lint
make pre-commit         # or: make fmt-check validate lint
```

- `make init` inits the root module, both examples, and `wrappers/`. Run it before `make validate`.
- Example `plan`/`apply` needs `TF_VAR_arvancloud_api_key` and a real test domain; destroy afterwards. See [examples/basic/README.md](examples/basic/README.md).
- Do not commit `*.tfvars`, `.terraform.lock.hcl`, or state files (all gitignored).

## Conventions

- `terraform fmt`; snake_case names; descriptions on every variable and output; validation blocks for inputs. TFLint enforces documented/typed vars and standard module structure.
- Record `type` values are **lowercase**: `a`, `aaaa`, `aname`, `caa`, `cname`, `dkim`, `mx`, `ns`, `ptr`, `spf`, `srv`, `tlsa`, `txt`.
- Apex name is `@`. CNAME/ANAME/MX/NS/SRV hostnames must be FQDNs ending with `.`.
- Always set an explicit `key` on records (especially duplicates). Auto keys are `{name}_{type}_{index}` — inserting or reordering the list without custom keys recreates resources. Keys must be unique per record type.
- `cloud` defaults to `true` for A/AAAA/CNAME/ANAME and `false` otherwise. Do not enable CDN proxy on mail/security records.
- When adding a record type, update `variables.tf` (schema + validations), `main.tf` (local map + resource), `outputs.tf`, [README.md](README.md), and `examples/`. Follow the existing per-type resource pattern.
- Examples: [examples/basic](examples/basic) is the minimal consumer; [examples/advanced](examples/advanced) covers all types, `ip_filter_mode`, and custom keys.
- Conventional Commits (`feat`, `fix`, `docs`, `chore`, `ci`, …).
