## Terraform template to deply Magento [1] with Varnish in AWS.
(Terraform v0.12.25, provider.aws v2.63.0)
### Main components:

1 magento server

1 varnish server

1 ALB with three listeners, forwarding incomming connections on HTTP to HTTPS. All requests should go to varnish unles ```/media/*``` and ```/static/*``` paths.

This deployment launches the resources in a new VPC.

### To apply:
```
export AWS_ACCESS_KEY_ID="<AWS access key>"
export AWS_SECRET_ACCESS_KEY="<AWS secret access key>"
export AWS_DEFAULT_REGION="<region>"

git clone https://github.com/mstelles/magento
cd magento
terraform init
terraform plan
terraform apply
```

[1] https://devdocs.magento.com/guides/v2.3/install-gde/prereq/nginx.html
