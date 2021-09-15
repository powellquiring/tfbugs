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

resource "ibm_is_instance" "fun" {
  name           = "${var.basename}-fun"
  vpc            = ibm_is_vpc.vpc.id
  zone           = local.zones[var.zone_index]
  keys           = [data.ibm_is_ssh_key.ssh_key.id]
  image          = data.ibm_is_image.ubuntu.id
  profile        = var.profile
  resource_group = data.ibm_resource_group.group.id

  primary_network_interface {
    subnet          = ibm_is_subnet.subnets[local.zones[var.zone_index]].id
  }
  # user_data = "a" # STEP_0
  user_data = "b" # STEP_1
}
resource "ibm_is_floating_ip" "fun" {
  name           = "${var.basename}-fun"
  target         = ibm_is_instance.fun.primary_network_interface[var.zone_index].id
  resource_group = data.ibm_resource_group.group.id
}

output "sshfun" {
  value = "ssh root@${ibm_is_floating_ip.fun.address}"
}
