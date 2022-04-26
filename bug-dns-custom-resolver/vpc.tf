resource "ibm_is_vpc" "location" {
  name                      = var.prefix
  resource_group            = local.resource_group
  address_prefix_management = "manual"
}

resource "ibm_is_vpc_address_prefix" "locations" {
  name = var.prefix
  zone = local.zone
  vpc  = ibm_is_vpc.location.id
  cidr = "10.0.0.0/16"
}

resource "ibm_is_subnet" "front" {
  depends_on      = [ibm_is_vpc_address_prefix.locations]
  name            = "${var.prefix}-front"
  resource_group  = local.resource_group
  vpc             = ibm_is_vpc.location.id
  zone            = local.zone
  ipv4_cidr_block = "10.0.0.0/24"
}

resource "ibm_is_subnet" "back" {
  depends_on      = [ibm_is_vpc_address_prefix.locations]
  name            = "${var.prefix}-back"
  resource_group  = local.resource_group
  vpc             = ibm_is_vpc.location.id
  zone            = local.zone
  ipv4_cidr_block = "10.0.1.0/24"
}

