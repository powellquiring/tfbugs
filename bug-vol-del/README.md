# Reproduce

```
cp template.local.env local.env
edit local.env
./doit.sh
```

Here is a cut down of the deletion steps that fail and result in a pending_deletion state for the volume.  The problem is likely that the ibm_iam_authorization_policy is deleted before the volume is deleted:


```
+ terraform destroy -auto-approve
ibm_iam_authorization_policy.policy: Destroying... [id=ac696d70-a654-4e2f-8252-e4ede5ba9e3e]
ibm_is_instance.mains: Destroying... [id=02h7_598b5ccb-27a7-44ef-bd7f-0d7979b36050]
ibm_iam_authorization_policy.policy: Destruction complete after 0s
ibm_is_instance.mains: Still destroying... [id=02h7_598b5ccb-27a7-44ef-bd7f-0d7979b36050, 10s elapsed]
...
ibm_is_instance.mains: Destruction complete after 1m43s
ibm_is_volume.mains: Destroying... [id=r026-71041d42-6909-4037-8e4b-96de33e49730]
ibm_is_subnet.mains: Destroying... [id=02h7-6c093fc2-314e-4f63-ba4b-839cfe936b38]
ibm_is_subnet.mains: Still destroying... [id=02h7-6c093fc2-314e-4f63-ba4b-839cfe936b38, 10s elapsed]
ibm_is_volume.mains: Still destroying... [id=r026-71041d42-6909-4037-8e4b-96de33e49730, 10s elapsed]
ibm_is_subnet.mains: Destruction complete after 14s
ibm_is_vpc_address_prefix.prefixes: Destroying... [id=r026-d85b8fea-667b-4df1-bf85-509b84dc3b9e/r026-d71afe1a-2ed3-4c1d-84c6-98f78aa9c40e]
ibm_is_vpc_address_prefix.prefixes: Destruction complete after 1s
ibm_is_vpc.main: Destroying... [id=r026-d85b8fea-667b-4df1-bf85-509b84dc3b9e]
ibm_is_volume.mains: Still destroying... [id=r026-71041d42-6909-4037-8e4b-96de33e49730, 20s elapsed]
ibm_is_vpc.main: Still destroying... [id=r026-d85b8fea-667b-4df1-bf85-509b84dc3b9e, 10s elapsed]
ibm_is_vpc.main: Destruction complete after 12s
ibm_is_volume.mains: Still destroying... [id=r026-71041d42-6909-4037-8e4b-96de33e49730, 30s elapsed]
...
ibm_is_volume.mains: Still destroying... [id=r026-71041d42-6909-4037-8e4b-96de33e49730, 4m20s elapsed]
```
