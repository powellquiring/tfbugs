data "ibm_resource_group" "group" {
  name = var.resource_group_name
}

locals {
  provider_region = var.region
  name            = var.basename
  tags = [
    "basename:${var.basename}",
    replace("dir:${abspath(path.root)}", "/", "_"),
  ]
  resource_group = data.ibm_resource_group.group.id
  cidr           = "10.0.0.0/8"
  prefixes = { for zone_number in range(3) : zone_number => {
    cidr = cidrsubnet(local.cidr, 8, zone_number)
    zone = "${var.region}-${zone_number + 1}"
  } }
}


resource "ibm_is_vpc" "location" {
  name                      = local.name
  resource_group            = local.resource_group
  address_prefix_management = "manual"
  tags                      = local.tags
}

resource "ibm_is_vpc_address_prefix" "locations" {
  for_each = local.prefixes
  name     = "${local.name}-${each.key}"
  zone     = each.value.zone
  vpc      = ibm_is_vpc.location.id
  cidr     = each.value.cidr
}

# This is the first attempt at locking down  more tightly based on security groups
# Now the default security group can be removed from some of the resources
# - back end load_balancer - now
# - instances - No, they need private dns access on port 53 ip addresses 161.26.0.10/11
# - front end load balancer - no, it needs to allow port 8000 from anywhere
resource ibm_is_security_group load_balancer_targets {
  name     = "${local.name}-load-balancer-targets"
  vpc      = ibm_is_vpc.location.id
  resource_group = data.ibm_resource_group.group.id
}

# the load balancer has outbound traffic to targets listening on port 8000
# the front end target has outbound traffic to the backend load balancer on port 8000
# (backend targets do not need outbound to 8000)
resource "ibm_is_security_group_rule" "load_balancer_targets_outbound" {
  direction = "outbound"
  group = ibm_is_security_group.load_balancer_targets.id
  remote = ibm_is_security_group.load_balancer_targets.id
  tcp {
    port_min = 8000
    port_max = 8000
  }
}

# the targets will receive input from their load load_balancers on port 8000
# the backend load balancer will receive input from the front end targets on port 8000
# (the front end load balancer will not need inbound traffic from this security group)
resource "ibm_is_security_group_rule" "load_balancer_targets_inbound" {
  direction = "inbound"
  group = ibm_is_security_group.load_balancer_targets.id
  remote = ibm_is_security_group.load_balancer_targets.id
  tcp {
    port_min = 8000
    port_max = 8000
  }
}

locals {
  subnets_front = { for zone_number in range(var.subnets) : zone_number => {
    cidr = cidrsubnet(ibm_is_vpc_address_prefix.locations[zone_number].cidr, 8, 0) # need a dependency on address prefix
    zone = local.prefixes[zone_number].zone
  } }
  subnets_back = { for zone_number in range(var.subnets) : zone_number => {
    cidr = cidrsubnet(ibm_is_vpc_address_prefix.locations[zone_number].cidr, 8, 1) # need a dependency on address prefix
    zone = local.prefixes[zone_number].zone
  } }
}

resource "ibm_is_subnet" "front" {
  for_each        = local.subnets_front
  name            = "${var.basename}-front-${each.key}"
  resource_group  = local.resource_group
  vpc             = ibm_is_vpc.location.id
  zone            = each.value.zone
  ipv4_cidr_block = each.value.cidr
}

resource "ibm_is_subnet" "back" {
  for_each        = local.subnets_back
  name            = "${var.basename}-back-${each.key}"
  resource_group  = local.resource_group
  vpc             = ibm_is_vpc.location.id
  zone            = each.value.zone
  ipv4_cidr_block = each.value.cidr
}

resource "ibm_is_lb" "front" {
  name           = "${local.name}-front"
  subnets        = [for subnet in ibm_is_subnet.front : subnet.id]
  type           = "public"
  resource_group = local.resource_group
}

resource ibm_is_security_group_target load_balancer_targets_front {
  security_group = ibm_is_security_group.load_balancer_targets.id
  target = ibm_is_lb.front.id
}


resource "ibm_is_lb" "back" {
  name           = "${local.name}-back"
  subnets        = [for subnet in ibm_is_subnet.back : subnet.id]
  type           = "private"
  resource_group = local.resource_group
}

resource ibm_is_security_group_target load_balancer_targets_back {
  security_group = ibm_is_security_group.load_balancer_targets.id
  target = ibm_is_lb.back.id
}

resource "ibm_is_security_group_rule" "inbound_8000" {
  group     = ibm_is_vpc.location.default_security_group
  direction = "inbound"
  tcp {
    port_min = 8000
    port_max = 8000
  }
}

resource "ibm_is_lb_pool" "front" {
  lb                  = ibm_is_lb.front.id
  name                = "front"
  protocol            = "http"
  algorithm           = "round_robin"
  health_delay        = "5"
  health_retries      = "2"
  health_timeout      = "2"
  health_type         = "http"
  health_monitor_url  = "/health"
  health_monitor_port = "8000"
}

resource "ibm_is_lb_listener" "front" {
  lb           = ibm_is_lb.front.id
  port         = "8000"
  protocol     = "http"
  default_pool = ibm_is_lb_pool.front.id
}
