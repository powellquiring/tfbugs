variable "ibmcloud_api_key" {}
variable "region" {
  default = "us-south"
}
variable "prefix" {
  default = "bugtf"
}
variable "resource_group" {
  default = "default"
}
variable "zone" {
  default = "1"
}

locals {
  resource_group = data.ibm_resource_group.group.id
  zone           = "${var.region}-${var.zone}"
}

data "ibm_resource_group" "group" {
  name = var.resource_group
}

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
}
