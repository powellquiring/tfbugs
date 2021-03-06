resource "ibm_resource_instance" "kp_data" {
  name              = "${local.name}-kp-data"
  service           = "kms"
  plan              = "tiered-pricing"
  location          = var.region
  resource_group_id = local.resource_group.id
}

resource "ibm_kp_key" "key_protect" {

  # [volume stays in pending_deletion when IAM authorization is revoked before deleting](https://jiracloud.swg.usma.ibm.com:8443/browse/SC-1935)
  depends_on = [ ibm_iam_authorization_policy.policy ] # comment this out to reproduce bug

  key_protect_id = ibm_resource_instance.kp_data.guid
  key_name       = "${local.name}-kp-data"
  standard_key   = false
}

resource "ibm_iam_authorization_policy" "policy" {
  source_service_name         = "server-protect"
  target_service_name         = "kms"
  target_resource_instance_id = ibm_resource_instance.kp_data.guid
  roles                       = ["Reader"]
}
