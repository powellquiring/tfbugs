/*
# resources - posgresql and cloud object storage with associated endpoint gateway and security groups

//------------------------------------------------
// postgresql
resource "ibm_database" "postgresql" {
  name              = "${local.BASENAME_CLOUD}-pg"
  resource_group_id = data.ibm_resource_group.all_rg.id
  plan              = "standard"
  service           = "databases-for-postgresql"
  location          = var.region
  service_endpoints = "private"
  tags              = local.tags
}

resource "ibm_resource_key" "postgresql" {
  name                 = "${local.BASENAME_CLOUD}-pg-key"
  resource_instance_id = ibm_database.postgresql.id
  # todo role?
  role = "Administrator"
  tags = local.tags
}

resource "time_sleep" "wait_for_postgresql_initialization" {
  depends_on = [
    ibm_database.postgresql
  ]
  create_duration = "5m"
}
resource "ibm_is_security_group" "posgresql" {
  name           = "${local.BASENAME_CLOUD}-posgresql"
  vpc            = ibm_is_vpc.cloud.id
  resource_group = data.ibm_resource_group.all_rg.id
}

locals {
  postgresql_credentials = jsonencode(nonsensitive(ibm_resource_key.postgresql.credentials))
}
*/

//------------------------------------------------
// cos
# cos 
locals {
  # reverse engineer this by creating one by hand:
  cos_endpoint = "s3.direct.${var.region}.cloud-object-storage.appdomain.cloud"
}
resource "ibm_resource_instance" "cos" {
  name              = "${local.BASENAME_CLOUD}-cos"
  resource_group_id = data.ibm_resource_group.all_rg.id
  service           = "cloud-object-storage"
  plan              = "standard"
  location          = "global"
  tags              = local.tags
}

resource "ibm_resource_key" "cos" {
  name                 = "${local.BASENAME_CLOUD}-cos-key"
  resource_instance_id = ibm_resource_instance.cos.id
  role                 = "Writer"

  parameters = {
    service-endpoints = "private"
  }
  tags = local.tags
}

