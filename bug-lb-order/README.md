# Issue
https://github.com/IBM-Cloud/terraform-provider-ibm/issues/3204

# Steps

```
cp template.local.env local.env
vi local.env; # fill in the values
terraform init
./test.sh
```

# Analysis
Deletion fails

This creates a load balancer and a security group and then attaches the security group to the load balancer.
During deletion the load balancer pool and listeners get deleted at the same time as the security group.  
The security group target deletion fails because the load balancer is UPDATE_PENDING.


Example log:

```
Plan: 0 to add, 0 to change, 18 to destroy.
ibm_is_security_group_target.load_balancer_targets_back: Destroying... [id=r014-4fb70abf-8ba9-43ea-97b3-ea676ba52dd1/r014-2b681290-16b7-4ab5-a7e6-9eb647b405cd]
ibm_is_security_group_target.load_balancer_targets_front: Destroying... [id=r014-4fb70abf-8ba9-43ea-97b3-ea676ba52dd1/r014-8fac077a-7c3f-49d3-9cb8-f071149d1231]
ibm_is_security_group_rule.load_balancer_targets_outbound: Destroying... [id=r014-4fb70abf-8ba9-43ea-97b3-ea676ba52dd1.r014-2d0d0f1b-7ea6-4e3f-bbda-654b2f59df06]
ibm_is_security_group_rule.load_balancer_targets_inbound: Destroying... [id=r014-4fb70abf-8ba9-43ea-97b3-ea676ba52dd1.r014-87ef45a0-e13e-4e58-a8f7-3303e308991c]
ibm_is_security_group_rule.inbound_8000: Destroying... [id=r014-fd68a7ea-ed5a-4989-9c0b-b451297156cd.r014-14d63ced-b2f7-4670-961c-6466e836a70a]
ibm_is_lb_listener.front: Destroying... [id=r014-8fac077a-7c3f-49d3-9cb8-f071149d1231/r014-e1d1776a-99b1-4f44-9e3e-75e41a8e6b32]
ibm_is_security_group_rule.inbound_8000: Destruction complete after 1s
ibm_is_security_group_rule.load_balancer_targets_outbound: Destruction complete after 1s
ibm_is_security_group_rule.load_balancer_targets_inbound: Destruction complete after 1s
ibm_is_security_group_target.load_balancer_targets_front: Destruction complete after 2s
ibm_is_security_group_target.load_balancer_targets_back: Destruction complete after 2s
ibm_is_lb.back: Destroying... [id=r014-2b681290-16b7-4ab5-a7e6-9eb647b405cd]
ibm_is_security_group.load_balancer_targets: Destroying... [id=r014-4fb70abf-8ba9-43ea-97b3-ea676ba52dd1]
ibm_is_lb_listener.front: Still destroying... [id=r014-8fac077a-7c3f-49d3-9cb8-f071149d12...4-e1d1776a-99b1-4f44-9e3e-75e41a8e6b32, 10s elapsed]
ibm_is_lb_listener.front: Still destroying... [id=r014-8fac077a-7c3f-49d3-9cb8-f071149d12...4-e1d1776a-99b1-4f44-9e3e-75e41a8e6b32, 20s elapsed]
ibm_is_lb_listener.front: Still destroying... [id=r014-8fac077a-7c3f-49d3-9cb8-f071149d12...4-e1d1776a-99b1-4f44-9e3e-75e41a8e6b32, 30s elapsed]
ibm_is_lb_listener.front: Still destroying... [id=r014-8fac077a-7c3f-49d3-9cb8-f071149d12...4-e1d1776a-99b1-4f44-9e3e-75e41a8e6b32, 40s elapsed]
ibm_is_lb_listener.front: Still destroying... [id=r014-8fac077a-7c3f-49d3-9cb8-f071149d12...4-e1d1776a-99b1-4f44-9e3e-75e41a8e6b32, 50s elapsed]
ibm_is_lb_listener.front: Still destroying... [id=r014-8fac077a-7c3f-49d3-9cb8-f071149d12...4-e1d1776a-99b1-4f44-9e3e-75e41a8e6b32, 1m0s elapsed]
ibm_is_lb_listener.front: Still destroying... [id=r014-8fac077a-7c3f-49d3-9cb8-f071149d12...4-e1d1776a-99b1-4f44-9e3e-75e41a8e6b32, 1m10s elapsed]
ibm_is_lb_listener.front: Still destroying... [id=r014-8fac077a-7c3f-49d3-9cb8-f071149d12...4-e1d1776a-99b1-4f44-9e3e-75e41a8e6b32, 1m20s elapsed]
ibm_is_lb_listener.front: Still destroying... [id=r014-8fac077a-7c3f-49d3-9cb8-f071149d12...4-e1d1776a-99b1-4f44-9e3e-75e41a8e6b32, 1m30s elapsed]
ibm_is_lb_listener.front: Still destroying... [id=r014-8fac077a-7c3f-49d3-9cb8-f071149d12...4-e1d1776a-99b1-4f44-9e3e-75e41a8e6b32, 1m40s elapsed]
ibm_is_lb_listener.front: Destruction complete after 1m45s
ibm_is_lb_pool.front: Destroying... [id=r014-8fac077a-7c3f-49d3-9cb8-f071149d1231/r014-1973dc86-719f-49cc-95e8-ac3ddf4a59c7]
ibm_is_lb_pool.front: Still destroying... [id=r014-8fac077a-7c3f-49d3-9cb8-f071149d12...4-1973dc86-719f-49cc-95e8-ac3ddf4a59c7, 10s elapsed]
ibm_is_lb_pool.front: Still destroying... [id=r014-8fac077a-7c3f-49d3-9cb8-f071149d12...4-1973dc86-719f-49cc-95e8-ac3ddf4a59c7, 20s elapsed]
ibm_is_lb_pool.front: Still destroying... [id=r014-8fac077a-7c3f-49d3-9cb8-f071149d12...4-1973dc86-719f-49cc-95e8-ac3ddf4a59c7, 30s elapsed]
ibm_is_lb_pool.front: Still destroying... [id=r014-8fac077a-7c3f-49d3-9cb8-f071149d12...4-1973dc86-719f-49cc-95e8-ac3ddf4a59c7, 40s elapsed]
ibm_is_lb_pool.front: Destruction complete after 45s
ibm_is_lb.front: Destroying... [id=r014-8fac077a-7c3f-49d3-9cb8-f071149d1231]
ibm_is_lb.front: Still destroying... [id=r014-8fac077a-7c3f-49d3-9cb8-f071149d1231, 10s elapsed]
ibm_is_lb.front: Still destroying... [id=r014-8fac077a-7c3f-49d3-9cb8-f071149d1231, 20s elapsed]
ibm_is_lb.front: Still destroying... [id=r014-8fac077a-7c3f-49d3-9cb8-f071149d1231, 30s elapsed]
ibm_is_lb.front: Still destroying... [id=r014-8fac077a-7c3f-49d3-9cb8-f071149d1231, 40s elapsed]
ibm_is_lb.front: Still destroying... [id=r014-8fac077a-7c3f-49d3-9cb8-f071149d1231, 50s elapsed]
ibm_is_lb.front: Still destroying... [id=r014-8fac077a-7c3f-49d3-9cb8-f071149d1231, 1m0s elapsed]
ibm_is_lb.front: Still destroying... [id=r014-8fac077a-7c3f-49d3-9cb8-f071149d1231, 1m10s elapsed]
ibm_is_lb.front: Still destroying... [id=r014-8fac077a-7c3f-49d3-9cb8-f071149d1231, 1m20s elapsed]
ibm_is_lb.front: Still destroying... [id=r014-8fac077a-7c3f-49d3-9cb8-f071149d1231, 1m30s elapsed]
ibm_is_lb.front: Still destroying... [id=r014-8fac077a-7c3f-49d3-9cb8-f071149d1231, 1m40s elapsed]
ibm_is_lb.front: Still destroying... [id=r014-8fac077a-7c3f-49d3-9cb8-f071149d1231, 1m50s elapsed]
ibm_is_lb.front: Still destroying... [id=r014-8fac077a-7c3f-49d3-9cb8-f071149d1231, 2m0s elapsed]
ibm_is_lb.front: Still destroying... [id=r014-8fac077a-7c3f-49d3-9cb8-f071149d1231, 2m10s elapsed]
ibm_is_lb.front: Still destroying... [id=r014-8fac077a-7c3f-49d3-9cb8-f071149d1231, 2m20s elapsed]
ibm_is_lb.front: Still destroying... [id=r014-8fac077a-7c3f-49d3-9cb8-f071149d1231, 2m30s elapsed]
ibm_is_lb.front: Destruction complete after 2m35s
ibm_is_subnet.front["1"]: Destroying... [id=0767-319b72b5-d662-4598-8b95-280d15cce3fa]
ibm_is_subnet.front["0"]: Destroying... [id=0757-0f548140-7f95-4a69-9d8f-22f56972a063]
ibm_is_subnet.front["0"]: Still destroying... [id=0757-0f548140-7f95-4a69-9d8f-22f56972a063, 10s elapsed]
ibm_is_subnet.front["1"]: Still destroying... [id=0767-319b72b5-d662-4598-8b95-280d15cce3fa, 10s elapsed]
ibm_is_subnet.front["0"]: Destruction complete after 16s
ibm_is_subnet.front["1"]: Destruction complete after 16s
╷
│ Error: Error Deleting Security Group Targets : error communicating with LBaaS: The load balancer with ID 'r014-8fac077a-7c3f-49d3-9cb8-f071149d1231' cannot be updated because its status is 'UPDATE_PENDING'.
│ {
│     "StatusCode": 409,
│     "Headers": {
│         "Cache-Control": [
│             "max-age=0, no-cache, no-store, must-revalidate"
│         ],
│         "Cf-Cache-Status": [
│             "DYNAMIC"
│         ],
│         "Cf-Ray": [
│             "69db9dd86fd1fdb9-PDX"
│         ],
│         "Content-Length": [
│             "470"
│         ],
│         "Content-Type": [
│             "application/json"
│         ],
│         "Date": [
│             "Wed, 13 Oct 2021 21:21:16 GMT"
│         ],
│         "Expect-Ct": [
│             "max-age=604800, report-uri=\"https://report-uri.cloudflare.com/cdn-cgi/beacon/expect-ct\""
│         ],
│         "Expires": [
│             "-1"
│         ],
│         "Pragma": [
│             "no-cache"
│         ],
│         "Server": [
│             "cloudflare"
│         ],
│         "Strict-Transport-Security": [
│             "max-age=31536000; includeSubDomains"
│         ],
│         "Vary": [
│             "Accept-Encoding"
│         ],
│         "X-Content-Type-Options": [
│             "nosniff"
│         ],
│         "X-Request-Id": [
│             "8dfa03a5-cf7a-4025-a643-3f48a096a32e"
│         ],
│         "X-Xss-Protection": [
│             "1; mode=block"
│         ]
│     },
│     "Result": {
│         "errors": [
│             {
│                 "code": "load_balancer_update_conflict",
│                 "message": "error communicating with LBaaS: The load balancer with ID 'r014-8fac077a-7c3f-49d3-9cb8-f071149d1231' cannot be updated because its status is 'UPDATE_PENDING'.",
│                 "more_info": "https://cloud.ibm.com/docs/vpc?topic=vpc-rias-error-messagesload_balancer_update_conflict",
│                 "target": {
│                     "name": "id",
│                     "type": "parameter",
│                     "value": "r014-8fac077a-7c3f-49d3-9cb8-f071149d1231"
│                 }
│             }
│         ],
│         "trace": "8dfa03a5-cf7a-4025-a643-3f48a096a32e"
│     },
│     "RawResult": null
│ }
│
│
│
╵
╷
│ Error: Error Deleting vpc load balancer : The load balancer with ID 'r014-2b681290-16b7-4ab5-a7e6-9eb647b405cd' cannot be deleted because its status is 'UPDATE_PENDING'.
│ {
│     "StatusCode": 409,
│     "Headers": {
│         "Cf-Cache-Status": [
│             "DYNAMIC"
│         ],
│         "Cf-Ray": [
│             "69db9ddc6822fdb9-PDX"
│         ],
│         "Content-Length": [
│             "344"
│         ],
│         "Content-Type": [
│             "application/json; charset=utf-8"
│         ],
│         "Date": [
│             "Wed, 13 Oct 2021 21:21:18 GMT"
│         ],
│         "Expect-Ct": [
│             "max-age=604800, report-uri=\"https://report-uri.cloudflare.com/cdn-cgi/beacon/expect-ct\""
│         ],
│         "Server": [
│             "cloudflare"
│         ],
│         "Strict-Transport-Security": [
│             "max-age=31536000;includeSubDomains"
│         ],
│         "Transaction-Id": [
│             "c989a7f5-a36a-4b0d-b015-552aa3b1ddd5"
│         ],
│         "Vary": [
│             "Accept-Encoding"
│         ],
│         "X-Content-Type-Options": [
│             "nosniff"
│         ],
│         "X-Request-Id": [
│             "c989a7f5-a36a-4b0d-b015-552aa3b1ddd5"
│         ]
│     },
│     "Result": {
│         "errors": [
│             {
│                 "code": "load_balancer_delete_conflict",
│                 "message": "The load balancer with ID 'r014-2b681290-16b7-4ab5-a7e6-9eb647b405cd' cannot be deleted because its status is 'UPDATE_PENDING'.",
│                 "more_info": "https://cloud.ibm.com/docs/vpc?topic=vpc-rias-error-messagesload_balancer_delete_conflict"
│             }
│         ],
│         "trace": "c989a7f5-a36a-4b0d-b015-552aa3b1ddd5"
│     },
│     "RawResult": null
│ }
│```



