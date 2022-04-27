resource "ibm_resource_instance" "cos" {
  name              = var.prefix
  resource_group_id = local.resource_group
  service           = "cloud-object-storage"
  plan              = "standard"
  location          = "global"
}

resource "ibm_cos_bucket" "flowlog" {
  bucket_name          = "${var.prefix}-002"
  resource_instance_id = ibm_resource_instance.cos.id
  region_location      = var.region
  # storage_class        = "flex"
  storage_class = "standard"
  force_delete  = true
}

