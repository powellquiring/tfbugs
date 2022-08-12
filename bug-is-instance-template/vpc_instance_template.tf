resource "ibm_is_instance_template" "instance_template" {
  name           = "${var.prefix}-template"
  image          = data.ibm_is_image.os.id
  profile        = "cx2-2x4"
  resource_group = local.resource_group

  primary_network_interface {
    subnet = ibm_is_subnet.front.id
  }
  vpc  = ibm_is_vpc.location.id
  zone = local.zone
  keys = [data.ibm_is_ssh_key.sshkey.id]

  lifecycle {
    create_before_destroy = true
  }
  /*
  terraform apply
  remove the volume_attachments below:
  terraform apply
  */
  volume_attachments {
    delete_volume_on_instance_delete = true
    name                             = "${var.prefix}-template-volume-attachment"
    volume_prototype {
      profile  = "general-purpose"
      capacity = 200
    }
  }
}
