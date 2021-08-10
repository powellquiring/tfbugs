variable "ibmcloud_api_key" { }
variable "ssh_key_name" { }
variable "resource_group_name" {
  default = "default"
}
variable "basename" {
  default = "bugroute"
}
variable "region" {
  default = "us-south"
}
variable "profile" {
  default = "cx2-2x4"
}
variable "image_name" {
  default = "ibm-ubuntu-18-04-1-minimal-amd64-2"
}

variable zone_index {
  default = 0
}
