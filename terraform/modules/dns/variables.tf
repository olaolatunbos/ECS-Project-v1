variable "zone_id" {
  description = "ID of the Route53 hosted zone the record is created in"
  type        = string
}

variable "record_name" {
  description = "The record name / hostname (e.g. staging.olaolat.com)"
  type        = string
}

variable "record_type" {
  description = "DNS record type"
  type        = string
  default     = "A"
}

variable "alias_dns_name" {
  description = "DNS name of the alias target (e.g. the ALB's DNS name)"
  type        = string
}

variable "alias_zone_id" {
  description = "Hosted zone ID of the alias target (e.g. the ALB's zone ID)"
  type        = string
}

variable "evaluate_target_health" {
  description = "Whether Route53 evaluates the health of the alias target"
  type        = bool
  default     = true
}
