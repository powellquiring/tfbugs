data "ibm_is_image" "ubuntu" {
  name = var.image_name
}
data "ibm_is_ssh_key" "ssh_key" {
  name = var.vpc_ssh_key_name
}

locals {
  tags     = []
  image_id = data.ibm_is_image.ubuntu.id
  user     = "root"
  keys     = [data.ibm_is_ssh_key.ssh_key.id]
  name     = var.basename
  cidr     = "10.0.0.0/8"
  capacity = 10
  resource_group = data.ibm_resource_group.group
  encryption_key =  ibm_kp_key.key_protect.crn
  subnets = {
    0 = {
      zone = "${var.region}-1"
      cidr = cidrsubnet(local.cidr, 8, 0)
      create_instance = true
    }
  }
  instances = {
    for key, subnet in local.subnets: key => ibm_is_subnet.mains[key] if subnet.create_instance
  }
}

data "ibm_resource_group" "group" {
  name = var.resource_group
}

resource "ibm_is_vpc" "main" {
  name                      = local.name
  resource_group            = local.resource_group.id
  address_prefix_management = "manual"
  tags                      = local.tags
}
resource "ibm_is_vpc_address_prefix" "prefixes" {
  for_each = local.subnets
  name     = "${local.name}-${each.key}"
  zone     = each.value.zone
  vpc      = ibm_is_vpc.main.id
  cidr     = each.value.cidr
}
resource "ibm_is_subnet" "mains" {
  for_each        = local.subnets
  name            = ibm_is_vpc_address_prefix.prefixes[each.key].name # need a dependency on address prefix
  vpc             = ibm_is_vpc.main.id
  zone            = each.value.zone
  ipv4_cidr_block = each.value.cidr
  resource_group  = local.resource_group.id
}

resource "ibm_is_volume" "mains" {
  for_each = local.instances
  name     = "${each.value.name}-data"
  profile  = "10iops-tier"
  zone     = each.value.zone
  encryption_key =  local.encryption_key
  capacity = local.capacity
}
resource "ibm_is_instance" "mains" {
  for_each = local.instances
  name           = each.value.name
  vpc            = ibm_is_vpc.main.id
  zone           = each.value.zone
  keys           = local.keys
  image          = local.image_id
  profile        = var.profile
  resource_group = local.resource_group.id
  primary_network_interface {
    subnet = each.value.id
  }
  boot_volume {
    name = "${each.value.name}-boot"
  }
  volumes   = [ibm_is_volume.mains[each.key].id]
  tags      = local.tags
}
