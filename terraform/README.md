You'll need to have a `terraform.tfvars` file. If you don't have that, then you probably don't have the correct state backup.

To make a change, run `tofu plan`, and then `tofu apply`.

## Formatting

`tofu fmt`

## View S3 state

`tofu state pull | jq '.'`