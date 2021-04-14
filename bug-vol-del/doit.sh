#/bin/bash
source local.env
set -ex
terraform init
terraform apply -auto-approve
sleep 20
terraform destroy -auto-approve
