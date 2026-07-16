output "certificate_arn" {
  description = "ARN of the validated ACM certificate"
  value       = aws_acm_certificate_validation.this.certificate_arn
}

output "zone_id" {
  description = "ID of the Route53 hosted zone"
  value       = data.aws_route53_zone.this.zone_id
}

output "domain_name" {
  description = "The certificate's domain name"
  value       = aws_acm_certificate.this.domain_name
}
