# Reproduce

```
cp template.local.env local.env
edit local.env
./doit.sh
```

## Volume in pending-deletion state

- [volume stays in pending_deletion when IAM authorization is revoked before deleting](https://jiracloud.swg.usma.ibm.com:8443/browse/SC-1935)
- See resources.tf - comment out line to reproduce bug




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
## volume not tainted
  - [ibm_is_volume not tainted on encryption_key removal](https://github.com/IBM-Cloud/terraform-provider-ibm/issues/2500)
  - see main.tf

## taint volume does not taint instance

  - [taint of ibm_is_volume should taint ibm_is_instance referencing the volume](https://github.com/IBM-Cloud/terraform-provider-ibm/issues/2501)
- 

taint of ibm_is_volume should taint ibm_is_instance referencing the volume

```
resource "ibm_is_volume" "mains" {
resource "ibm_is_instance" "mains" {
  volumes = [ibm_is_volume.mains.id]
```

Perform the following steps:

  - terraform apply
  - terraform taint ibm_is_volume.mains
  - terraform apply
  Expected: instance would be tainted
  Actual: instance is not tainted which results in the following error (volume still attached)

```
$ terraform taint ibm_is_volume.mains
Resource instance ibm_is_volume.mains has been marked as tainted.
$ terraform apply
ibm_is_vpc.main: Refreshing state... [id=r026-c8515a51-7977-4269-9e11-a89e44890519]
ibm_resource_instance.kp_data: Refreshing state... [id=crn:v1:bluemix:public:kms:au-syd:a/713c783d9a507a53135fe6793c37cc74:0d1f3ded-cfa3-4969-9fd6-772a0015da42::]
ibm_iam_authorization_policy.policy: Refreshing state... [id=0e11ed89-35f4-40c4-8c22-1a41c39fe240]
ibm_kp_key.key_protect: Refreshing state... [id=crn:v1:bluemix:public:kms:au-syd:a/713c783d9a507a53135fe6793c37cc74:0d1f3ded-cfa3-4969-9fd6-772a0015da42:key:1e3b6354-96a9-493c-9b1e-19dfef5db00d]
ibm_is_volume.mains: Refreshing state... [id=r026-6c0efce1-5beb-4727-a9f8-00e4472489b5]
ibm_is_vpc_address_prefix.prefixes: Refreshing state... [id=r026-c8515a51-7977-4269-9e11-a89e44890519/r026-6b638f2d-162e-4175-864e-e95b17b264d7]
ibm_is_subnet.mains: Refreshing state... [id=02h7-3926d60b-4958-4a3a-9856-cfff53602667]
ibm_is_instance.mains: Refreshing state... [id=02h7_7e6e14ae-d1af-44c6-8cda-b8474f9bcec9]

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  ~ update in-place
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # ibm_is_instance.mains will be updated in-place
  ~ resource "ibm_is_instance" "mains" {
        id                      = "02h7_7e6e14ae-d1af-44c6-8cda-b8474f9bcec9"
        name                    = "bb02"
        tags                    = []
      ~ volumes                 = [
          - "r026-6c0efce1-5beb-4727-a9f8-00e4472489b5",
        ] -> (known after apply)
        # (17 unchanged attributes hidden)


        # (2 unchanged blocks hidden)
    }

  # ibm_is_volume.mains is tainted, so must be replaced
-/+ resource "ibm_is_volume" "mains" {
      ~ crn                     = "crn:v1:bluemix:public:is:au-syd-1:a/713c783d9a507a53135fe6793c37cc74::volume:r026-6c0efce1-5beb-4727-a9f8-00e4472489b5" -> (known after apply)
      ~ id                      = "r026-6c0efce1-5beb-4727-a9f8-00e4472489b5" -> (known after apply)
      ~ iops                    = 3000 -> (known after apply)
        name                    = "bb02"
      ~ resource_controller_url = "https://cloud.ibm.com/vpc-ext/storage/storageVolumes" -> (known after apply)
      ~ resource_crn            = "crn:v1:bluemix:public:is:au-syd-1:a/713c783d9a507a53135fe6793c37cc74::volume:r026-6c0efce1-5beb-4727-a9f8-00e4472489b5" -> (known after apply)
      ~ resource_group          = "b6503f25836d49029966ab5be7fe50b5" -> (known after apply)
      ~ resource_group_name     = "default" -> (known after apply)
      ~ resource_name           = "bb02" -> (known after apply)
      ~ resource_status         = "available" -> (known after apply)
      ~ status                  = "available" -> (known after apply)
      ~ status_reasons          = [] -> (known after apply)
      ~ tags                    = [] -> (known after apply)
        # (4 unchanged attributes hidden)
    }

Plan: 1 to add, 1 to change, 1 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

ibm_is_volume.mains: Destroying... [id=r026-6c0efce1-5beb-4727-a9f8-00e4472489b5]

Error: Error Deleting Volume : The volume is still attached to an instance.
{
    "StatusCode": 409,
    "Headers": {
        "Cache-Control": [
            "max-age=0, no-cache, no-store, must-revalidate"
        ],
        "Cf-Cache-Status": [
            "DYNAMIC"
        ],
        "Cf-Ray": [
            "6401d41cdf82fdb9-PDX"
        ],
        "Cf-Request-Id": [
            "097502e60a0000fdb9f2bfd000000001"
        ],
        "Connection": [
            "keep-alive"
        ],
        "Content-Length": [
            "240"
        ],
        "Content-Type": [
            "application/json; charset=utf-8"
        ],
        "Date": [
            "Thu, 15 Apr 2021 02:43:52 GMT"
        ],
        "Expect-Ct": [
            "max-age=604800, report-uri=\"https://report-uri.cloudflare.com/cdn-cgi/beacon/expect-ct\""
        ],
        "Expires": [
            "-1"
        ],
        "Pragma": [
            "no-cache"
        ],
        "Server": [
            "cloudflare"
        ],
        "Set-Cookie": [
            "__cfduid=dffe4e97b302b8b5db04f766ac2ea72b71618454629; expires=Sat, 15-May-21 02:43:49 GMT; path=/; domain=.iaas.cloud.ibm.com; HttpOnly; SameSite=Lax; Secure"
        ],
        "Strict-Transport-Security": [
            "max-age=31536000; includeSubDomains"
        ],
        "Transaction-Id": [
            "ae27b606e186322af0ed42a6768c1ee1"
        ],
        "Vary": [
            "Accept-Encoding"
        ],
        "X-Content-Type-Options": [
            "nosniff"
        ],
        "X-Request-Id": [
            "ae27b606e186322af0ed42a6768c1ee1"
        ],
        "X-Xss-Protection": [
            "1; mode=block"
        ]
    },
    "Result": {
        "errors": [
            {
                "code": "volume_still_attached",
                "message": "The volume is still attached to an instance.",
                "more_info": "http://www.bluemix.com/help#volume_still_attached",
                "target": {
                    "name": "",
                    "type": ""
                }
            }
        ],
        "trace": "ae27b606e186322af0ed42a6768c1ee1"
    },
    "RawResult": null
}
```
