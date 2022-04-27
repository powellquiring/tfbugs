To create a new bug see if the stuff you need is in bug-template.  If not consider adding it for next time.  At least use the main.tf, versions.tf file

```
cp -r bug-template bug-new
cd bug-new
# rm -rf .terraform* terraform.tfstate*
# rm cos.tf ... terraform that is not needed for the bug report
```

```
cp template.local.env local.env
vi local.env
source local.env
```
