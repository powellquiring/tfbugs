provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
}

terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "= 1.32.0"
    }
  }
  required_version = "= 1.0.6"
}

