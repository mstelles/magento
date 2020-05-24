output "vpc_id" {
  value       = "${aws_vpc.mainvpc.id}"
  description = "VPC ID"
}

output "alb_dns" {
  value       = "${aws_alb.magentoalb.dns_name}"
  description = "ALB FQDN"
}

output "varnish_instance_id" {
  value       = "${aws_instance.varnish.id}"
  description = "Varnish instance ID"
}

output "magento_instance_id" {
  value       = "${aws_instance.magento.id}"
  description = "Magento instance ID"
}

output "Varnish_FQDN" {
  value       = "${aws_instance.varnish.public_dns}"
  description = "The public FQDN for the Varnish server instance"
}

output "Magento_FQDN" {
  value       = "${aws_instance.magento.public_dns}"
  description = "The public FQDN for the Magento server instance"
}
