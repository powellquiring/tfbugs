variable ibmcloud_api_key {}

locals {
  region = "us-south"
  provider_region = local.region
  name = "tfbug-bucket"
  resource_group = data.ibm_resource_group.group.id
}

data "ibm_resource_group" "group" {
  name = "default"
}

resource "ibm_resource_instance" "cos" {
  name              = local.name
  resource_group_id = local.resource_group
  service           = "cloud-object-storage"
  plan              = "standard"
  location          = "global"
}

resource "ibm_cos_bucket" "flowlog" {
  bucket_name          = "${local.name}-000"
  resource_instance_id = ibm_resource_instance.cos.id
  region_location      = local.region
  # storage_class        = "flex"
  storage_class        = "smart"
  # storage_class        = "standard"
  force_delete         = true
}
