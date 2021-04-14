#/bin/bash
source local.env
set -ex
terraform apply -auto-approve
sleep 20
terraform destroy -auto-approve
