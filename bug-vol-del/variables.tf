variable "ibmcloud_api_key" {}
variable "region" {}
variable "basename" {}
variable "vpc_ssh_key_name" {}
variable "resource_group" {}

variable "image_name" {
  default = "ibm-ubuntu-18-04-1-minimal-amd64-2"
}
variable "profile" {
  default = "cx2-2x4"
}

