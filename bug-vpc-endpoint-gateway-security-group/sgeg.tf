resource "ibm_is_security_group" "cos" {
  name           = "${local.BASENAME_CLOUD}-cos"
  vpc            = ibm_is_vpc.cloud.id
  resource_group = data.ibm_resource_group.all_rg.id
}

resource "ibm_is_security_group_rule" "cloud_ingress_cos" {
  group     = ibm_is_security_group.cos.id
  direction = "inbound"
  remote    = "10.0.0.0/8" // on prem and cloud
  tcp {
    port_min = 443
    port_max = 443
  }
}
resource "ibm_is_security_group_rule" "cloud_egress_cos" {
  group     = ibm_is_security_group.cos.id
  direction = "outbound"
  remote    = "10.0.0.0/8" // on prem and cloud
}

resource "ibm_is_virtual_endpoint_gateway" "cos" {
  vpc            = ibm_is_vpc.cloud.id
  name           = "${local.BASENAME_CLOUD}-cos"
  resource_group = data.ibm_resource_group.all_rg.id
  target {
    crn           = "crn:v1:bluemix:public:cloud-object-storage:global:::endpoint:${local.cos_endpoint}"
    resource_type = "provider_cloud_service"
  }

  security_groups = [ibm_is_security_group.cos.id]

  # one Reserved IP per zone in the VPC
  ips {
    subnet = ibm_is_subnet.cloud.id
    name   = "cos"
  }
  tags = local.tags
}
