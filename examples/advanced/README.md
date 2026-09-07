# Advanced Example

Advanced consumer of the ArvanCloud CDN DNS module: all record types, load balancing, `ip_filter_mode`, and custom keys.

The domain must already exist in ArvanCloud CDN. This example does not create a zone.

## What This Example Creates

### A Records

- Apex with weighted load balancing across 2 servers
- API subdomain with round-robin load balancing
- Monitoring subdomains (Grafana, Prometheus)

### AAAA Records

- IPv6 records with weighted load balancing

### CNAME Records

- WWW redirect to root domain
- CDN subdomain
- Documentation (GitHub Pages)
- Status page

### ANAME Records

- Apex alias for a hostname

### MX Records

- 3 mail servers with different priorities (10, 20, 50)

### TXT Records

- SPF record for email authentication
- DKIM record for email signing
- DMARC record for email policy
- Domain verification records (Google, GitHub)

### SPF & DKIM Records

- Dedicated SPF and DKIM record types

### CAA Records

- Certificate Authority Authorization (issue, issuewild, iodef)

### NS Records

- Subdomain delegation to external nameservers

### SRV Records

- SIP service discovery
- XMPP server discovery
- Autodiscover for email clients

### TLSA Records

- TLS certificate pinning for HTTPS

### PTR Records

- Reverse DNS for mail server

## Features Demonstrated

| Feature              | Description                               |
| -------------------- | ----------------------------------------- |
| Load Balancing       | Weighted and round-robin distribution     |
| Multiple Origins     | Primary and secondary servers             |
| CDN Integration      | Cloud-enabled records with HTTPS upstream |
| Email Security       | Complete SPF, DKIM, DMARC setup           |
| Certificate Security | CAA and TLSA records                      |
| Service Discovery    | SRV records for various services          |
| Subdomain Delegation | NS records for external management        |

## Usage

1. Set your API key:

   ```bash
   export TF_VAR_arvancloud_api_key="your-api-key"
   ```

2. Customize variables (optional):

   ```bash
   cat > terraform.tfvars << EOF
   domain = "example.ir"
   EOF
   ```

3. Initialize, plan, and apply against a **test** domain:

   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. Destroy when finished:

   ```bash
   terraform destroy
   ```

Do not commit `terraform.tfvars`, lock files, or state.

## Inputs

| Name               | Description                              | Type     | Default        |
| ------------------ | ---------------------------------------- | -------- | -------------- |
| arvancloud_api_key | ArvanCloud API key                       | `string` | n/a            |
| domain             | Existing CDN domain to manage records on | `string` | `"example.ir"` |

## Outputs

| Name           | Description                                  |
| -------------- | -------------------------------------------- |
| domain         | Domain managed by the module                 |
| all_record_ids | Map of all DNS record IDs organized by type  |
| record_count   | Count of DNS records by type including total |
| a_records      | A record details                             |
| cname_records  | CNAME record details                         |
| mx_records     | MX record details                            |
| txt_records    | TXT record details                           |

## Customization

To customize this example for your infrastructure:

1. Update the `locals.origins` block with your server IPs
2. Modify email settings (MX, SPF, DKIM, DMARC) for your mail provider
3. Adjust TTL values based on your caching requirements
4. Add or remove records as needed
5. Keep explicit `key` values on records that share a name and type

## Notes

- Records with `cloud = true` are proxied through ArvanCloud CDN
- Records with `cloud = false` are DNS-only (no CDN proxy). Leave mail and security records unproxied.
- FQDN values for CNAME, ANAME, MX, NS, and SRV must end with a dot (e.g. `example.ir.`)
- Multiple records with the same name and type require unique `key` values
