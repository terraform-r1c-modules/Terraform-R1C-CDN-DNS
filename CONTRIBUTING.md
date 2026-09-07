# Contributing to ArvanCloud CDN DNS Terraform Module

Thank you for considering contributing to this project.

## Table of Contents

- [Contributing to ArvanCloud CDN DNS Terraform Module](#contributing-to-arvancloud-cdn-dns-terraform-module)
  - [Table of Contents](#table-of-contents)
  - [Code of Conduct](#code-of-conduct)
  - [Getting Started](#getting-started)
  - [Development Setup](#development-setup)
    - [Prerequisites](#prerequisites)
    - [Install Development Tools](#install-development-tools)
    - [Verify Setup](#verify-setup)
  - [How to Contribute](#how-to-contribute)
    - [Reporting Bugs](#reporting-bugs)
    - [Suggesting Features](#suggesting-features)
    - [Submitting Code Changes](#submitting-code-changes)
  - [Style Guidelines](#style-guidelines)
    - [Terraform Code Style](#terraform-code-style)
    - [File Organization](#file-organization)
    - [Naming Conventions](#naming-conventions)
  - [Commit Messages](#commit-messages)
    - [Types](#types)
    - [Examples](#examples)
  - [Pull Request Process](#pull-request-process)
  - [Testing](#testing)
    - [Local Testing](#local-testing)
    - [Integration Testing](#integration-testing)
  - [Documentation](#documentation)
  - [Questions?](#questions)

## Code of Conduct

This project and everyone participating in it is governed by our commitment to providing a welcoming and inclusive environment. Please be respectful and constructive in all interactions.

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:

   ```bash
   git clone https://github.com/terraform-r1c-modules/Terraform-R1C-DNS.git
   cd Terraform-R1C-DNS
   ```

3. **Add the upstream remote**:

   ```bash
   git remote add upstream https://github.com/terraform-r1c-modules/Terraform-R1C-DNS.git
   ```

4. **Create a branch** for your changes:

   ```bash
   git checkout -b feat/your-feature-name
   ```

## Development Setup

### Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.5
- [TFLint](https://github.com/terraform-linters/tflint)
- [pre-commit](https://pre-commit.com/)

### Install Development Tools

```bash
pip install pre-commit
make pre-commit-install

# TFLint (Linux)
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
```

### Verify Setup

```bash
terraform version
tflint --version
pre-commit --version
make help
```

## How to Contribute

### Reporting Bugs

- Use the [Bug Report](../../issues/new?template=bug_report.yml) template
- Include Terraform and provider versions
- Provide minimal reproduction steps
- Include error messages and logs

### Suggesting Features

- Use the [Feature Request](../../issues/new?template=feature_request.yml) template
- Explain the use case and benefits
- Consider backward compatibility

### Submitting Code Changes

1. Follow the [style guidelines](#style-guidelines)
2. Update documentation and examples
3. Run `make check` (or `make pre-commit`)
4. Submit a pull request

## Style Guidelines

### Terraform Code Style

- Use `terraform fmt` to format all `.tf` files
- Use snake_case names
- Add descriptions to all variables and outputs
- Use validation blocks for inputs
- Follow [HashiCorp's Terraform style conventions](https://developer.hashicorp.com/terraform/language/syntax/style)

```hcl
# Good
variable "domain" {
  description = "Existing ArvanCloud CDN domain (name or UUID) whose DNS records this module manages."
  type        = string
  nullable    = false

  validation {
    condition     = length(trimspace(var.domain)) > 0
    error_message = "Domain name cannot be empty."
  }
}

# Bad
variable "domain" {
  type = string
}
```

### File Organization

```plaintext
.
├── main.tf              # Per-type arvancloud_cdn_domain_dns_record resources
├── variables.tf         # Module contract
├── outputs.tf           # Output values
├── versions.tf          # required_version and required_providers only
├── Makefile             # Local fmt / validate / lint
├── README.md            # Usage and schemas
├── examples/
│   ├── basic/           # Minimal consumer (provider lives here)
│   └── advanced/        # All record types
└── wrappers/            # for_each wrapper for Terragrunt-style maps
```

Do not add a `provider "arvancloud"` block or a backend in the module root. Put those in consumer roots (`examples/*`). Keep records in HCL — do not introduce YAML inventories.

### Naming Conventions

- **Variables / locals / outputs**: `snake_case`
- **Resources**: `{type}_records` with `for_each` (e.g. `a_records`)
- **Record types**: lowercase (`a`, `aaaa`, `cname`, …)
- **Apex name**: `@`

When adding a record type, update `variables.tf` (schema + validations), `main.tf` (local map + resource), `outputs.tf`, `README.md`, and `examples/`. Follow the existing per-type resource pattern.

## Commit Messages

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```plaintext
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks
- `ci`: CI/CD changes

### Examples

```plaintext
feat: add unique key validation for duplicate records

fix: reject CNAME hosts that are not FQDNs

docs: document CDN proxy defaults for mail records

chore: align Makefile targets with local quality gates
```

## Pull Request Process

1. **Update your branch** with the latest upstream changes:

   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Run validation checks**:

   ```bash
   make init
   make check
   ```

3. **Push your changes** and create a pull request

4. **Fill out the PR template** completely

5. **Wait for review** — maintainers will review your PR and may request changes

6. **Address feedback** by pushing additional commits

7. Once approved, a maintainer will **merge your PR**

Do not commit `*.tfvars`, `.terraform.lock.hcl`, or state files (all gitignored).

## Testing

### Local Testing

```bash
make init
make check          # fmt-check + validate + lint
make pre-commit     # all pre-commit hooks
```

`make validate` requires `make init` first so each Terraform directory has a `.terraform` folder.

### Integration Testing

Example `plan`/`apply` needs `TF_VAR_arvancloud_api_key` and a real test domain. Destroy afterwards.

1. Set ArvanCloud API credentials
2. Use a dedicated test domain
3. Run `terraform apply` from `examples/basic` (see [examples/basic/README.md](examples/basic/README.md))
4. Verify records in the ArvanCloud panel
5. Run `terraform destroy` to clean up

## Documentation

- Update `README.md` for any changes to variables, outputs, or usage
- Update examples to demonstrate new features
- Keep `CHANGELOG.md` current (Keep a Changelog)
- Use proper Markdown formatting

## Questions?

If you have questions:

- Open a [Question issue](../../issues/new?template=question.yml)
- Start a [Discussion](../../discussions)

Thank you for contributing.
