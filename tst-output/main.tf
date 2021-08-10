variable "ibmcloud_api_key" {}
variable "region" {}
variable "resource_group_name" {}
variable "basename" {
  default = "tst-output"
}

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
  generation       = 2
}

data "ibm_resource_group" "group" {
  name = var.resource_group_name
}

locals {
  make_s0 = true
  make_s1 = true
}

locals {
  name     = var.basename
  zone     = "${var.region}-1"
  vpc_cidr = "10.0.0.0/16"
}
resource "ibm_is_vpc" "tst" {
  name                      = local.name
  resource_group            = data.ibm_resource_group.group.id
  address_prefix_management = "manual"
}
resource "ibm_is_vpc_address_prefix" "tst" {
  name = local.name
  zone = local.zone
  vpc             = ibm_is_vpc.tst.id
  cidr = local.vpc_cidr
}


resource "ibm_is_subnet" "tst0" {
  count           = local.make_s0 ? 1 : 0
  name            = "${local.name}-0"
  vpc             = ibm_is_vpc.tst.id
  zone            = local.zone
  ipv4_cidr_block = cidrsubnet(ibm_is_vpc_address_prefix.tst.cidr, 8, 0)
  resource_group  = data.ibm_resource_group.group.id
}
resource "ibm_is_subnet" "tst1" {
  count           = local.make_s1 ? 1 : 0
  name            = "${local.name}-1"
  vpc             = ibm_is_vpc.tst.id
  zone            = local.zone
  ipv4_cidr_block = cidrsubnet(ibm_is_vpc_address_prefix.tst.cidr, 8, 1)
  resource_group  = data.ibm_resource_group.group.id
}

output vx {
  value = "vx"
}

output stuff {
  value = merge(
    {for subnet in ibm_is_subnet.tst0: subnet.name => subnet.ipv4_cidr_block},
    {for key, subnet in ibm_is_subnet.tst1: "sub1" => {
      name = ibm_is_subnet.tst1[key].name
    }}
  )
}
/*
*/
