data "ibm_is_image" "ubuntu" {
  name = var.image_name
}
data "ibm_is_ssh_key" "ssh_key" {
  name = var.vpc_ssh_key_name
}

locals {
  tags           = []
  image_id       = data.ibm_is_image.ubuntu.id
  user           = "root"
  keys           = [data.ibm_is_ssh_key.ssh_key.id]
  name           = var.basename
  big_cidr       = "10.0.0.0/8"
  capacity       = 10
  resource_group = data.ibm_resource_group.group
  encryption_key = ibm_kp_key.key_protect.crn
  # encryption_key =  "crn:v1:bluemix:public:kms:au-syd:a/713c783d9a507a53135fe6793c37cc74:9e6c26f1-a4b9-4a9c-9a2c-bf5d84cfba4c:key:25abfd00-7d50-4556-b489-c96bc5ac130e"
  zone = "${var.region}-1"
  cidr = cidrsubnet(local.big_cidr, 8, 0)
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
  name = local.name
  zone = local.zone
  vpc  = ibm_is_vpc.main.id
  cidr = local.cidr
}
resource "ibm_is_subnet" "mains" {
  name            = ibm_is_vpc_address_prefix.prefixes.name # need a dependency on address prefix
  vpc             = ibm_is_vpc.main.id
  zone            = local.zone
  ipv4_cidr_block = local.cidr
  resource_group  = local.resource_group.id
}

resource "ibm_is_volume" "mains" {
  # depends_on = [ibm_iam_authorization_policy.policy]
  name           = local.name
  profile        = "10iops-tier"
  zone           = local.zone
  encryption_key = local.encryption_key
  capacity       = local.capacity
}
resource "ibm_is_instance" "mains" {
  name           = local.name
  vpc            = ibm_is_vpc.main.id
  zone           = local.zone
  keys           = local.keys
  image          = local.image_id
  profile        = var.profile
  resource_group = local.resource_group.id
  primary_network_interface {
    subnet = ibm_is_subnet.mains.id
  }
  boot_volume {
    name = "${local.name}-boot"
  }
  volumes = [ibm_is_volume.mains.id]
  tags    = local.tags
}
