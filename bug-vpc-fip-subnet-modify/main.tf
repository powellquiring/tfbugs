locals{
  zones = [
    "${var.region}-1",
    "${var.region}-2",
    "${var.region}-3",
  ]
}

data "ibm_resource_group" "group" {
  name = var.resource_group_name
}

resource "ibm_is_vpc" "vpc" {
  name           = var.basename
  resource_group = data.ibm_resource_group.group.id
}

resource "ibm_is_security_group" "sg1" {
  name           = "${var.basename}-sg1"
  vpc            = ibm_is_vpc.vpc.id
  resource_group = data.ibm_resource_group.group.id
}

resource "ibm_is_security_group_rule" "inbound_all" {
  group     = ibm_is_security_group.sg1.id
  direction = "inbound"
  remote    = "0.0.0.0/0" # TOO OPEN for production
}

resource "ibm_is_security_group_rule" "outbound_all" {
  group     = ibm_is_security_group.sg1.id
  direction = "outbound"
  remote    = "0.0.0.0/0" # TOO OPEN for production
}

resource "ibm_is_subnet" "subnets" {
  for_each = toset(local.zones)
  name                     = "${var.basename}-${each.key}"
  vpc                      = ibm_is_vpc.vpc.id
  zone                     = each.key
  total_ipv4_address_count = 256
  resource_group = data.ibm_resource_group.group.id
}

data "ibm_is_ssh_key" "ssh_key" {
  name = var.ssh_key_name
}

data "ibm_is_image" "ubuntu" {
  name = var.image_name
}

resource "ibm_is_instance" "proxy" {
  name           = "${var.basename}-proxy"
  vpc            = ibm_is_vpc.vpc.id
  zone           = local.zones[0]
  keys           = [data.ibm_is_ssh_key.ssh_key.id]
  image          = data.ibm_is_image.ubuntu.id
  profile        = var.profile
  resource_group = data.ibm_resource_group.group.id

  primary_network_interface {
    subnet          = ibm_is_subnet.paloalto[local.zones[0]].id
    security_groups = [ibm_is_security_group.sg1.id]
  }
}

resource "ibm_is_instance" "host" {
  name           = "${var.basename}-host"
  vpc            = ibm_is_vpc.vpc.id
  zone           = local.zones[0]
  keys           = [data.ibm_is_ssh_key.ssh_key.id]
  image          = data.ibm_is_image.ubuntu.id
  profile        = var.profile
  resource_group = data.ibm_resource_group.group.id

  primary_network_interface {
    subnet          = ibm_is_subnet.paloalto[local.zones[0]].id
    security_groups = [ibm_is_security_group.sg1.id]
  }
}

resource "ibm_is_floating_ip" "proxy" {
  name           = "${var.basename}-proxy"
  target         = ibm_is_instance.proxy.primary_network_interface[var.zone_index].id
  resource_group = data.ibm_resource_group.group.id
}

resource "ibm_is_floating_ip" "host" {
  name           = "${var.basename}-host"
  target         = ibm_is_instance.host.primary_network_interface[var.zone_index].id
  resource_group = data.ibm_resource_group.group.id
}

#---
output "sshproxy" {
  value = "ssh root@${ibm_is_floating_ip.proxy.address}"
}
output "sshhost" {
  value = "ssh root@${ibm_is_floating_ip.host.address}"
}
