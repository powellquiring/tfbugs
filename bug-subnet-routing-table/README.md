# subnet change routing table to null

Expected changing the subnet to null would be deleted then added.
Actual no changes

- initial state, apply:
```
  routing_table   = ibm_is_vpc_routing_table.location.routing_table
  # routing_table   = null
```

- change state, then apply

```
  # routing_table   = ibm_is_vpc_routing_table.location.routing_table
  routing_table   = null
```

results:

```
➜  bug-subnet-routing-table git:(master) ✗ tfa
ibm_is_vpc.vpc: Refreshing state... [id=r006-42cbc2eb-120b-462c-8b64-b03ea860a876]
ibm_is_vpc_routing_table.location: Refreshing state... [id=r006-42cbc2eb-120b-462c-8b64-b03ea860a876/r006-eb9d3823-4884-49aa-b40a-2d627e42988a]
ibm_is_subnet.subnets: Refreshing state... [id=0717-46bde1f2-4b11-408b-b75f-e4ae075a60db]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are
needed.

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
```



