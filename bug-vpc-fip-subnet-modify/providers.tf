provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
  generation       = 2
}

terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.20.0"
    }
  }
  required_version = ">= 0.13.0"
}

