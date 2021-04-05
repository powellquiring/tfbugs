variable basename {}
variable ibmcloud_api_key {}
variable region {}
variable resource_group_name {}

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
  generation       = 2
}

data "ibm_resource_group" "group" {
  name = var.resource_group_name
}

locals {
  name = var.basename
  resource_group_id = data.ibm_resource_group.group.id
  cidr0 = "192.168.0.0/24"
  zone = "${var.region}-1"
}

resource "ibm_is_vpc" "main" {
  name                      = local.name
  resource_group            = local.resource_group_id
  address_prefix_management = "manual"
}

resource "ibm_is_vpc_address_prefix" "main" {
  name     = local.name
  zone     = local.zone
  vpc      = ibm_is_vpc.main.id
  cidr     = local.cidr0
}
resource "ibm_is_subnet" "main" {
  name     = local.name
  vpc            = ibm_is_vpc_address_prefix.main.vpc
  zone            = ibm_is_vpc_address_prefix.main.zone
  ipv4_cidr_block = ibm_is_vpc_address_prefix.main.cidr
  resource_group  = local.resource_group_id
}

resource "ibm_database" "redis" {
  name              = local.name
  resource_group_id = local.resource_group_id
  plan              = "standard"
  service           = "databases-for-redis"
  location          = var.region
  service_endpoints = "private"
}

resource "ibm_resource_key" "resource_key" {
  name                 = local.name
  resource_instance_id = ibm_database.redis.id
  role                 = "Administrator"
}

