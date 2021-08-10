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
  tags = [
    "dir:/a",
  ]
}

resource "ibm_is_vpc" "vpc" {
  name = "bug-vpc-tags"
  resource_group = data.ibm_resource_group.group.id
  address_prefix_management = "manual"
  tags = local.tags
}
