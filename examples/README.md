# Examples

Runnable consumer roots for this module. Each example configures the ArvanCloud provider; the module itself does not.

| Example              | What it shows                                                       |
| -------------------- | ------------------------------------------------------------------- |
| [basic](basic)       | A, MX, and TXT records with explicit `key` values                   |
| [advanced](advanced) | All record types, load balancing, `ip_filter_mode`, and custom keys |

`plan` and `apply` need `TF_VAR_arvancloud_api_key` and a real test domain. Destroy afterwards.

```bash
export TF_VAR_arvancloud_api_key="your-api-key"
cd examples/basic
terraform init
terraform apply -var="domain=example.ir"
terraform destroy -var="domain=example.ir"
```
