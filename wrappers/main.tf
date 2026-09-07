module "wrapper" {
  source = "../"

  for_each = var.items

  domain  = try(each.value.domain, var.defaults.domain)
  records = try(each.value.records, var.defaults.records, [])
}
