variable "arvancloud_api_key" {
  description = "ArvanCloud API key for authentication."
  type        = string
  sensitive   = true
  nullable    = false
}

variable "domain" {
  description = "Existing ArvanCloud CDN domain to manage DNS records on."
  type        = string
  default     = "example.ir"
  nullable    = false
}
