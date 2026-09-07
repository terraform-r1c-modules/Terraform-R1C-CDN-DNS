# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Input validations for remaining record types, unique keys per type, FQDN hostnames, IPv4/IPv6 addresses, and TLSA/SRV/MX ranges
- `domain` output
- `wrappers/` module for Terragrunt-style `for_each` over domains
- `make check` aggregate target and `terraform -chdir` loops for all Terraform directories

### Changed

- Documented the real GitHub repository (`Terraform-R1C-DNS`), provider setup, and existing-domain scope
- Makefile, EditorConfig, Git attributes, pre-commit hooks, and example consumer files

## [v1.0.1] - 2026-01-02

### Fixed

- Support duplicate record names for eligible DNS record types like TXT and MX.

## [v1.0.0] - 2026-01-02

### Added

- Initial release of the ArvanCloud CDN DNS Terraform Module

[Unreleased]: https://github.com/terraform-r1c-modules/Terraform-R1C-DNS/compare/v1.0.1...HEAD
[v1.0.1]: https://github.com/terraform-r1c-modules/Terraform-R1C-DNS/releases/tag/v1.0.1
[v1.0.0]: https://github.com/terraform-r1c-modules/Terraform-R1C-DNS/releases/tag/v1.0.0
