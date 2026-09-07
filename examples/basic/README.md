# Basic Example

Minimal consumer of the ArvanCloud CDN DNS module: A, MX, and TXT records with explicit `key` values.

The domain must already exist in ArvanCloud CDN. This example does not create a zone.

## What This Example Creates

- A record for the apex (`@`)
- A record for `www`
- A record for `api`
- MX record for email
- TXT records for SPF and domain verification (custom keys)

## Usage

1. Set your API key:

   ```bash
   export TF_VAR_arvancloud_api_key="your-api-key"
   ```

2. Initialize, plan, and apply against a **test** domain:

   ```bash
   terraform init
   terraform plan -var="domain=example.ir"
   terraform apply -var="domain=example.ir"
   ```

3. Destroy when finished:

   ```bash
   terraform destroy -var="domain=example.ir"
   ```

Do not commit `terraform.tfvars`, lock files, or state.

## Inputs

| Name               | Description                              | Type     | Default        |
| ------------------ | ---------------------------------------- | -------- | -------------- |
| arvancloud_api_key | ArvanCloud API key                       | `string` | n/a            |
| domain             | Existing CDN domain to manage records on | `string` | `"example.ir"` |

## Outputs

| Name         | Description                       |
| ------------ | --------------------------------- |
| domain       | Domain managed by the module      |
| record_ids   | Map of all DNS record IDs by type |
| record_count | Count of DNS records by type      |
