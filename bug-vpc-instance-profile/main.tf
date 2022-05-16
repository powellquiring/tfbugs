variable "region" {}
variable "prefix" {}
variable "resource_group" {}
variable "ssh_key_name" {}
variable "zone" {
  default = "1"
}

/////////////////////////////////////////
variable "profile" {
  default = "cx2-2x4"
  //default = "cx2d-2x4"
}
variable "cloud_image_name" {
  default = "ibm-ubuntu-18-04-1-minimal-amd64-2"
}

/////////////////////////////////////////
provider "ibm" {
  region           = var.region
}

/////////////////////////////////////////
data "ibm_resource_group" "group" {
  name = var.resource_group
}

data "ibm_is_ssh_key" "sshkey" {
  name = var.ssh_key_name
}

data "ibm_is_image" "os" {
  name = var.cloud_image_name
}

/////////////////////////////////////////
locals {
  resource_group = data.ibm_resource_group.group.id
  zone           = "${var.region}-${var.zone}"
}
