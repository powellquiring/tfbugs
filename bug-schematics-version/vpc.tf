resource "ibm_is_vpc" "location" {
  name                      = var.prefix
  resource_group            = local.resource_group
  address_prefix_management = "manual"
}

