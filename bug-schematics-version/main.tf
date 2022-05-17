variable "region" {
  default = "us-south"
}
variable "prefix" {
  default = "tfbug04"
}
variable "resource_group" {
  default = "default"
}
variable "zone" {
  default = "1"
}

/////////////////////////////////////////
variable "profile" {
  default = "cx2-2x4"
}
variable "cloud_image_name" {
  default = "ibm-ubuntu-18-04-1-minimal-amd64-2"
}

/////////////////////////////////////////
provider "ibm" {
  region = var.region
}

/////////////////////////////////////////
data "ibm_resource_group" "group" {
  name = var.resource_group
}

/////////////////////////////////////////
locals {
  resource_group = data.ibm_resource_group.group.id
  zone           = "${var.region}-${var.zone}"
}
