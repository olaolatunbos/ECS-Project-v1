output "fqdn" {
  description = "Fully-qualified domain name of the created record"
  value       = aws_route53_record.this.fqdn
}

output "name" {
  description = "Name of the created record"
  value       = aws_route53_record.this.name
}
