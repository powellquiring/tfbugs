locals{
  zones = [
    "${var.region}-1",
    "${var.region}-2",
    "${var.region}-3",
  ]
}

data "ibm_resource_group" "group" {
  name = var.resource_group_name
}

resource "ibm_is_vpc" "vpc" {
  name           = var.basename
  resource_group = data.ibm_resource_group.group.id
}

resource "ibm_is_vpc_routing_table" "location" {
  name  = var.basename
  vpc   = ibm_is_vpc.vpc.id
}

resource "ibm_is_subnet" "subnets" {
  name                     = var.basename
  vpc                      = ibm_is_vpc.vpc.id
  zone                     = local.zones[0]
  total_ipv4_address_count = 256
  resource_group = data.ibm_resource_group.group.id
  # terraform apply then switch the comments on these two lines:
  routing_table   = ibm_is_vpc_routing_table.location.routing_table
  # routing_table   = null
}

