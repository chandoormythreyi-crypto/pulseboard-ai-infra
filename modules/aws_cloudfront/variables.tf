variable "name" {
  description = "The name of the CloudFront distribution"
  type        = string
}

variable "description" {
  description = "Description for the CloudFront distribution"
  type        = string
  default     = ""
}

variable "app_bucket_domain_name" {
  description = "Domain name of the S3 bucket for the app"
  type        = string
}

variable "app_bucket_id" {
  description = "ID of the S3 bucket for the app"
  type        = string
}

variable "env" {
  type        = string
  description = "The environment (dev | staging | prod)."
  validation {
    condition     = contains(["dev", "staging", "prod"], var.env)
    error_message = "The env value must be one of: dev, staging, prod."
  }
}


variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}

variable "app_cache_min_ttl" {
  description = "Minimum TTL (in seconds) for the default (app) CloudFront cache behavior. Must be non-negative."
  type        = number
  default     = 0

  validation {
    condition     = var.app_cache_min_ttl >= 0
    error_message = "The app_cache_min_ttl must be greater than or equal to 0."
  }
}

variable "app_cache_default_ttl" {
  description = "Default TTL (in seconds) for the default (app) CloudFront cache behavior. Must be >= app_cache_min_ttl."
  type        = number
  default     = 3600 # 1 hour

  validation {
    condition     = var.app_cache_default_ttl >= var.app_cache_min_ttl
    error_message = "The app_cache_default_ttl must be greater than or equal to app_cache_min_ttl."
  }
}

variable "app_cache_max_ttl" {
  description = "Maximum TTL (in seconds) for the default (app) CloudFront cache behavior. Must be >= app_cache_default_ttl."
  type        = number
  default     = 86400 # 24 hours

  validation {
    condition     = var.app_cache_max_ttl >= var.app_cache_default_ttl
    error_message = "The app_cache_max_ttl must be greater than or equal to app_cache_default_ttl."
  }
}

variable "aliases" {
  description = "List of alternate domain names (CNAMEs) for the CloudFront distribution"
  type        = list(string)
  default     = []
}

variable "create_certificate" {
  description = "Whether to create an ACM certificate for the aliases"
  type        = bool
  default     = true
}

variable "ssl_support_method" {
  description = "Method that CloudFront uses to serve HTTPS requests"
  type        = string
  default     = "sni-only"

  validation {
    condition     = var.ssl_support_method == null || contains(["vip", "sni-only", "static-ip"], var.ssl_support_method)
    error_message = "The ssl_support_method must be one of: vip, sni-only, or static-ip."
  }
}

variable "minimum_protocol_version" {
  description = "Minimum version of the SSL protocol that CloudFront uses for HTTPS connections"
  type        = string
  default     = "TLSv1.2_2021"

  validation {
    condition = contains([
      "SSLv3", "TLSv1", "TLSv1_2016", "TLSv1.1_2016", "TLSv1.2_2018",
      "TLSv1.2_2019", "TLSv1.2_2021"
    ], var.minimum_protocol_version)
    error_message = "The minimum_protocol_version must be a valid TLS/SSL protocol version supported by CloudFront."
  }
}
