# new instance causes error in fip
Find the full test here:

After changing the value of user_data in an ibm_is_instance with an associated ibm_is_floating_ip the creation of the floating_ip fails

```
resource "ibm_is_instance" "fun" {
...
  user_data = "a" # STEP_0
  # user_data = "b" # STEP_1
}

resource "ibm_is_floating_ip" "fun" {
  name           = "${var.basename}-fun"
  target         = ibm_is_instance.fun.primary_network_interface[var.zone_index].id
  resource_group = data.ibm_resource_group.group.id
}

$ tfa
<change from STEP_0 to STEP_1
$ tfa
```

Results in the following in the apply after the change:

```
➜  bug-vpc-fip-instance-modify git:(master) ✗ tfa
ibm_is_vpc.vpc: Refreshing state... [id=r006-006189e7-e122-490d-8459-2dfda57b2fb5]
ibm_is_subnet.subnets["us-south-1"]: Refreshing state... [id=0717-e05e2f72-099a-4c32-b2fc-0f49a03308cc]
ibm_is_subnet.subnets["us-south-3"]: Refreshing state... [id=0737-2deee2bb-5b89-465b-9551-d5195bf11f50]
ibm_is_subnet.subnets["us-south-2"]: Refreshing state... [id=0727-aa46e70f-dea3-4957-8606-92242f1278ee]
ibm_is_instance.fun: Refreshing state... [id=0717_a869c2b2-16ad-4c53-9a9b-5e44d240438c]
ibm_is_floating_ip.fun: Refreshing state... [id=r006-0dd8bc2c-dd80-4f31-96e1-5cb514382964]

Note: Objects have changed outside of Terraform

Terraform detected the following changes made outside of Terraform since the last "terraform apply":

  # ibm_is_subnet.subnets["us-south-1"] has been changed
  ~ resource "ibm_is_subnet" "subnets" {
      ~ available_ipv4_address_count = 251 -> 250
        id                           = "0717-e05e2f72-099a-4c32-b2fc-0f49a03308cc"
        name                         = "vpcfipbug-us-south-1"
        tags                         = []
        # (16 unchanged attributes hidden)
    }
  # ibm_is_vpc.vpc has been changed
  ~ resource "ibm_is_vpc" "vpc" {
        id                          = "r006-006189e7-e122-490d-8459-2dfda57b2fb5"
        name                        = "vpcfipbug"
      ~ subnets                     = [
          + {
              + available_ipv4_address_count = 250
              + id                           = "0717-e05e2f72-099a-4c32-b2fc-0f49a03308cc"
              + name                         = "vpcfipbug-us-south-1"
              + status                       = "available"
              + total_ipv4_address_count     = 256
              + zone                         = "us-south-1"
            },
          + {
              + available_ipv4_address_count = 251
              + id                           = "0727-aa46e70f-dea3-4957-8606-92242f1278ee"
              + name                         = "vpcfipbug-us-south-2"
              + status                       = "available"
              + total_ipv4_address_count     = 256
              + zone                         = "us-south-2"
            },
          + {
              + available_ipv4_address_count = 251
              + id                           = "0737-2deee2bb-5b89-465b-9551-d5195bf11f50"
              + name                         = "vpcfipbug-us-south-3"
              + status                       = "available"
              + total_ipv4_address_count     = 256
              + zone                         = "us-south-3"
            },
        ]
        tags                        = []
        # (20 unchanged attributes hidden)
    }

Unless you have made equivalent changes to your configuration, or ignored the relevant attributes using ignore_changes,
the following plan may include actions to undo or respond to these changes.

───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the
following symbols:
  ~ update in-place
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # ibm_is_floating_ip.fun will be updated in-place
  ~ resource "ibm_is_floating_ip" "fun" {
        id                      = "r006-0dd8bc2c-dd80-4f31-96e1-5cb514382964"
        name                    = "vpcfipbug-fun"
        tags                    = []
      ~ target                  = "0717-464d38ba-3cb7-4db6-884e-897459d95656" -> (known after apply)
        # (9 unchanged attributes hidden)
    }

  # ibm_is_instance.fun must be replaced
-/+ resource "ibm_is_instance" "fun" {
      ~ disks                   = [] -> (known after apply)
      ~ gpu                     = [] -> (known after apply)
      ~ id                      = "0717_a869c2b2-16ad-4c53-9a9b-5e44d240438c" -> (known after apply)
      ~ memory                  = 4 -> (known after apply)
        name                    = "vpcfipbug-fun"
      ~ placement_target        = [] -> (known after apply)
      ~ resource_controller_url = "https://cloud.ibm.com/vpc-ext/compute/vs" -> (known after apply)
      ~ resource_crn            = "crn:v1:bluemix:public:is:us-south-1:a/713c783d9a507a53135fe6793c37cc74::instance:0717_a869c2b2-16ad-4c53-9a9b-5e44d240438c" -> (known after apply)
      ~ resource_group_name     = "default" -> (known after apply)
      ~ resource_name           = "vpcfipbug-fun" -> (known after apply)
      ~ resource_status         = "running" -> (known after apply)
      ~ status                  = "running" -> (known after apply)
      ~ status_reasons          = [] -> (known after apply)
      ~ tags                    = [] -> (known after apply)
      ~ user_data               = "a" -> "b" # forces replacement
      ~ vcpu                    = [
          - {
              - architecture = "amd64"
              - count        = 2
            },
        ] -> (known after apply)
      ~ volume_attachments      = [
          - {
              - id          = "0717-38821490-ff3a-41ef-9b25-2acfc1d54dad"
              - name        = "cartload-abundant-aim-phonics"
              - volume_crn  = "crn:v1:bluemix:public:is:us-south-1:a/713c783d9a507a53135fe6793c37cc74::volume:r006-97568a0b-67d2-427b-a8f6-9cedb1135488"
              - volume_id   = "r006-97568a0b-67d2-427b-a8f6-9cedb1135488"
              - volume_name = "earmuff-sandpit-reclusive-ride"
            },
        ] -> (known after apply)
        # (7 unchanged attributes hidden)

      ~ boot_volume {
          + encryption = (known after apply)
          ~ iops       = 3000 -> (known after apply)
          ~ name       = "earmuff-sandpit-reclusive-ride" -> (known after apply)
          ~ profile    = "general-purpose" -> (known after apply)
          ~ size       = 100 -> (known after apply)
          + snapshot   = (known after apply)
        }

      ~ primary_network_interface {
          ~ id                   = "0717-464d38ba-3cb7-4db6-884e-897459d95656" -> (known after apply)
          ~ name                 = "uncover-glitch-ranting-chunk" -> (known after apply)
          - port_speed           = 0 -> null
          ~ primary_ipv4_address = "10.240.0.4" -> (known after apply)
          ~ security_groups      = [
              - "r006-76e44b5e-dc3a-453c-ae61-3c548e5ec45e",
            ] -> (known after apply)
            # (2 unchanged attributes hidden)
        }
    }

Plan: 1 to add, 1 to change, 1 to destroy.
ibm_is_instance.fun: Destroying... [id=0717_a869c2b2-16ad-4c53-9a9b-5e44d240438c]
ibm_is_instance.fun: Still destroying... [id=0717_a869c2b2-16ad-4c53-9a9b-5e44d240438c, 10s elapsed]
ibm_is_instance.fun: Still destroying... [id=0717_a869c2b2-16ad-4c53-9a9b-5e44d240438c, 20s elapsed]
ibm_is_instance.fun: Still destroying... [id=0717_a869c2b2-16ad-4c53-9a9b-5e44d240438c, 30s elapsed]
ibm_is_instance.fun: Still destroying... [id=0717_a869c2b2-16ad-4c53-9a9b-5e44d240438c, 40s elapsed]
ibm_is_instance.fun: Still destroying... [id=0717_a869c2b2-16ad-4c53-9a9b-5e44d240438c, 50s elapsed]
ibm_is_instance.fun: Still destroying... [id=0717_a869c2b2-16ad-4c53-9a9b-5e44d240438c, 1m0s elapsed]
ibm_is_instance.fun: Destruction complete after 1m1s
ibm_is_instance.fun: Creating...
ibm_is_instance.fun: Still creating... [10s elapsed]
ibm_is_instance.fun: Still creating... [20s elapsed]
ibm_is_instance.fun: Still creating... [30s elapsed]
ibm_is_instance.fun: Still creating... [40s elapsed]
ibm_is_instance.fun: Still creating... [50s elapsed]
ibm_is_instance.fun: Still creating... [1m0s elapsed]
ibm_is_instance.fun: Creation complete after 1m8s [id=0717_796c68d5-f9a7-46cf-b8bc-992d5e2fda37]
╷
│ Error: Provider produced inconsistent final plan
│
│ When expanding the plan for ibm_is_floating_ip.fun to include new values learned so far during apply, provider
│ "registry.terraform.io/ibm-cloud/ibm" changed the planned action from Update to DeleteThenCreate.
│
│ This is a bug in the provider, which should be reported in the provider's own issue tracker.
╵
╷
│ Error: Provider produced inconsistent final plan
│
│ When expanding the plan for ibm_is_floating_ip.fun to include new values learned so far during apply, provider
│ "registry.terraform.io/ibm-cloud/ibm" produced an invalid new value for .zone: was known, but now unknown.
│
│ This is a bug in the provider, which should be reported in the provider's own issue tracker.
╵
╷
│ Error: Provider produced inconsistent final plan
│
│ When expanding the plan for ibm_is_floating_ip.fun to include new values learned so far during apply, provider
│ "registry.terraform.io/ibm-cloud/ibm" produced an invalid new value for .resource_controller_url: was known, but now
│ unknown.
│
│ This is a bug in the provider, which should be reported in the provider's own issue tracker.
╵
╷
│ Error: Provider produced inconsistent final plan
│
│ When expanding the plan for ibm_is_floating_ip.fun to include new values learned so far during apply, provider
│ "registry.terraform.io/ibm-cloud/ibm" produced an invalid new value for .resource_crn: was known, but now unknown.
│
│ This is a bug in the provider, which should be reported in the provider's own issue tracker.
╵
╷
│ Error: Provider produced inconsistent final plan
│
│ When expanding the plan for ibm_is_floating_ip.fun to include new values learned so far during apply, provider
│ "registry.terraform.io/ibm-cloud/ibm" produced an invalid new value for .resource_status: was known, but now unknown.
│
│ This is a bug in the provider, which should be reported in the provider's own issue tracker.
╵
╷
│ Error: Provider produced inconsistent final plan
│
│ When expanding the plan for ibm_is_floating_ip.fun to include new values learned so far during apply, provider
│ "registry.terraform.io/ibm-cloud/ibm" produced an invalid new value for .status: was known, but now unknown.
│
│ This is a bug in the provider, which should be reported in the provider's own issue tracker.
╵
╷
│ Error: Provider produced inconsistent final plan
│
│ When expanding the plan for ibm_is_floating_ip.fun to include new values learned so far during apply, provider
│ "registry.terraform.io/ibm-cloud/ibm" produced an invalid new value for .tags: was known, but now unknown.
│
│ This is a bug in the provider, which should be reported in the provider's own issue tracker.
╵
╷
│ Error: Provider produced inconsistent final plan
│
│ When expanding the plan for ibm_is_floating_ip.fun to include new values learned so far during apply, provider
│ "registry.terraform.io/ibm-cloud/ibm" produced an invalid new value for .address: was known, but now unknown.
│
│ This is a bug in the provider, which should be reported in the provider's own issue tracker.
╵
╷
│ Error: Provider produced inconsistent final plan
│
│ When expanding the plan for ibm_is_floating_ip.fun to include new values learned so far during apply, provider
│ "registry.terraform.io/ibm-cloud/ibm" produced an invalid new value for .id: was known, but now unknown.
│
│ This is a bug in the provider, which should be reported in the provider's own issue tracker.
╵
╷
│ Error: Provider produced inconsistent final plan
│
│ When expanding the plan for ibm_is_floating_ip.fun to include new values learned so far during apply, provider
│ "registry.terraform.io/ibm-cloud/ibm" produced an invalid new value for .resource_group_name: was known, but now
│ unknown.
│
│ This is a bug in the provider, which should be reported in the provider's own issue tracker.
╵
╷
│ Error: Provider produced inconsistent final plan
│
│ When expanding the plan for ibm_is_floating_ip.fun to include new values learned so far during apply, provider
│ "registry.terraform.io/ibm-cloud/ibm" produced an invalid new value for .resource_name: was known, but now unknown.
│
│ This is a bug in the provider, which should be reported in the provider's own issue tracker.
```



