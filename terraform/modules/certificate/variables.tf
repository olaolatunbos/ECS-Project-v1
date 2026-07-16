variable "domain_name" {
  description = "Fully-qualified domain name for the certificate (e.g. staging.olaolat.com)"
  type        = string
}

variable "hosted_zone_name" {
  description = "Route53 hosted zone the domain belongs to (e.g. olaolat.com)"
  type        = string
}
