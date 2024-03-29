variable "region" {}
variable "prefix" {}
variable "resource_group" {}
provider "ibm" {
  region = var.region
}

/////////////////////////////////////////
data "ibm_resource_group" "group" {
  name = var.resource_group
}

locals {
  resource_group = data.ibm_resource_group.group.id
}

resource "ibm_resource_instance" "dns_services_instance" {
  name              = "dns-services-for-vpc"
  service           = "dns-svcs"
  plan              = "standard-dns"
  resource_group_id = data.ibm_resource_group.group.id
  location          = "global"
}

resource "ibm_dns_zone" "dns_services_zone" {
  name        = "cloud.example.cloud"
  instance_id = ibm_resource_instance.dns_services_instance.guid
}

resource "ibm_dns_resource_record" "dns_services_resource_record_a" {
  instance_id = ibm_resource_instance.dns_services_instance.guid
  zone_id     = ibm_dns_zone.dns_services_zone.zone_id
  type        = "A"
  name        = "aaa-transit-z1-worker"
  rdata       = "10.0.0.4"
  ttl         = 3600
}

output "ibm_dns_resource_record" {
  value = ibm_dns_resource_record.dns_services_resource_record_a
}
output "name" {
  value = ibm_dns_resource_record.dns_services_resource_record_a.name
}
