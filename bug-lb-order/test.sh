#!/bin/bash
set -ex

terraform apply -auto-approve
terraform destroy -auto-approve
