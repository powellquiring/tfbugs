resource "ibm_is_floating_ip" "front" {
  resource_group = local.resource_group
  name           = "unattachedfip"
  # target         = ibm_is_instance.front.primary_network_interface[0].id
  zone           = local.zone
}

