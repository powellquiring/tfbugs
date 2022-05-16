resource "ibm_is_security_group_rule" "onprem_inbound_all" {
  group     = ibm_is_vpc.location.default_security_group
  direction = "inbound"
  remote    = "0.0.0.0/0"
}
resource "ibm_is_security_group_rule" "onprem_outbound_all" {
  group     = ibm_is_vpc.location.default_security_group
  direction = "outbound"
  remote    = "0.0.0.0/0"
}

resource "ibm_is_instance" "front" {
  name           = "${var.prefix}-front"
  image          = data.ibm_is_image.os.id
  profile        = var.profile
  vpc            = ibm_is_vpc.location.id
  zone           = local.zone
  keys           = [data.ibm_is_ssh_key.sshkey.id]
  resource_group = local.resource_group
  primary_network_interface {
    subnet = ibm_is_subnet.front.id
  }
}

resource "ibm_is_floating_ip" "front" {
  resource_group = local.resource_group
  name           = ibm_is_instance.front.name
  target         = ibm_is_instance.front.primary_network_interface[0].id
}

output "output" {
  value = <<-EOT
  ssh root@${ibm_is_floating_ip.front.address}
EOT
}
