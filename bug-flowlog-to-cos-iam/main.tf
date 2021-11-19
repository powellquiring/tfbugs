variable ibmcloud_api_key {}

locals {
  region = "us-south"
  provider_region = local.region
  name = "tfbug-flowlog-to-cos"
  resource_group = data.ibm_resource_group.group.id
}

data "ibm_resource_group" "group" {
  name = "default"
}

resource ibm_is_vpc source {
  name                      = local.name
  resource_group            = local.resource_group
}

resource "ibm_resource_instance" "cos" {
  name              = local.name
  resource_group_id = local.resource_group
  service           = "cloud-object-storage"
  plan              = "standard"
  location          = "global"
}

resource "ibm_iam_authorization_policy" "is_flowlog_write_to_cos" {
  source_service_name  = "is"
  source_resource_type = "flow-log-collector"
  target_service_name  = "cloud-object-storage"
  target_resource_instance_id = ibm_resource_instance.cos.id
  # target_resource_instance_id = ibm_resource_instance.cos.guid
  roles                = ["Writer"]
}

resource "ibm_cos_bucket" "flowlog" {
  depends_on = [ibm_iam_authorization_policy.is_flowlog_write_to_cos]
  bucket_name          = "${local.name}-001"
  resource_instance_id = ibm_resource_instance.cos.id
  region_location      = local.region
  #storage_class        = "flex"
  storage_class        = "standard"
  force_delete         = true
}

resource ibm_is_flow_log test_flowlog {
  name = local.name
  target = ibm_is_vpc.source.id
  active = true
  storage_bucket = ibm_cos_bucket.flowlog.bucket_name
}

