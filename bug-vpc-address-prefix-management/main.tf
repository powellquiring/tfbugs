variable ibmcloud_api_key {}
variable region {}
variable resource_group_name {}
variable basename {}

locals{
  zones = [
    "${var.region}-1",
    "${var.region}-2",
  ]
}

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
}

data "ibm_resource_group" "group" {
  name = var.resource_group_name
}

resource "ibm_is_vpc" "bug" {
  name = var.basename
  resource_group = data.ibm_resource_group.group.id
  # address_prefix_management = "auto"
  address_prefix_management = "manual"
}
