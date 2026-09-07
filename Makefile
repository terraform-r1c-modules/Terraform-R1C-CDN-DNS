# Makefile for Terraform module development

SHELL := /usr/bin/env bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help
.DELETE_ON_ERROR:
.SUFFIXES:

TF_DIRS := . examples/basic examples/advanced wrappers

.PHONY: help init init-upgrade validate fmt fmt-check lint check security pre-commit pre-commit-install clean

help: ## Show this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

init: ## Initialize Terraform in the root, examples, and wrappers
	@for dir in $(TF_DIRS); do \
		echo "==> terraform init $$dir"; \
		terraform -chdir=$$dir init -input=false; \
	done

init-upgrade: ## Initialize Terraform and upgrade providers
	@for dir in $(TF_DIRS); do \
		echo "==> terraform init -upgrade $$dir"; \
		terraform -chdir=$$dir init -input=false -upgrade; \
	done

validate: ## Validate Terraform configuration (run make init first)
	@for dir in $(TF_DIRS); do \
		echo "==> terraform validate $$dir"; \
		terraform -chdir=$$dir validate; \
	done

fmt: ## Format Terraform files
	terraform fmt -recursive

fmt-check: ## Check Terraform formatting
	terraform fmt -check -recursive -diff

lint: ## Run TFLint
	tflint --recursive

check: fmt-check validate lint ## Run format check, validate, and lint

security: ## Run Trivy config scan, falling back to tfsec
	@if command -v trivy >/dev/null 2>&1; then \
		trivy config --severity HIGH,CRITICAL .; \
	elif command -v tfsec >/dev/null 2>&1; then \
		tfsec .; \
	else \
		echo "error: install trivy or tfsec to run security scans" >&2; \
		exit 1; \
	fi

pre-commit: ## Run pre-commit hooks on all files
	pre-commit run --all-files

pre-commit-install: ## Install pre-commit hooks
	pre-commit install

clean: ## Remove local Terraform working files
	@find . -type d -name '.terraform' -prune -exec rm -rf {} +
	@find . -type f \( -name '.terraform.lock.hcl' -o -name '*.tfplan' -o -name 'terraform.tfstate' -o -name 'terraform.tfstate.*' -o -name '.terraform.tfstate.lock.info' \) -delete
