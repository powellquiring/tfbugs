resource "ibm_resource_instance" "dns" {
  name              = var.prefix
  resource_group_id = local.resource_group
  location          = "global"
  service           = "dns-svcs"
  plan              = "standard-dns"
}

resource "ibm_dns_custom_resolver" "location" {
  name        = var.prefix
  instance_id = ibm_resource_instance.dns.guid
  locations {
    subnet_crn = ibm_is_subnet.front.crn
    enabled    = true
  }
  locations {
    subnet_crn = ibm_is_subnet.front.crn
    // fix by using back instead of front
    // subnet_crn = ibm_is_subnet.back.crn
    enabled = true
  }
}
