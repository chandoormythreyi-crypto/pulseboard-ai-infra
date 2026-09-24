variable "bucket_name" {
  description = "The name of the S3 bucket."
  type        = string
}

variable "versioning" {
  description = "Enable versioning for the bucket."
  type        = bool
  default     = true
}

variable "enable_encryption" {
  description = "Enable server-side encryption by default."
  type        = bool
  default     = true
}

variable "sse_algorithm" {
  description = "The server-side encryption algorithm to use."
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "aws:kms", "aws:kms:dsse"], var.sse_algorithm)
    error_message = "Valid values are AES256, aws:kms, and aws:kms:dsse"
  }
}

variable "kms_master_key_id" {
  description = "ARN or ID of the KMS key to use for SSE-KMS encryption. Required when sse_algorithm is aws:kms or aws:kms:dsse; ignored for AES256."
  type        = string
  default     = null
}

variable "block_public_access" {
  description = "Block all public access to the bucket (sets all four S3 public access block options)."
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to assign to the bucket."
  type        = map(string)
  default     = {}
}

variable "policy" {
  description = "A valid bucket policy JSON document"
  type        = string
  default     = null
}

variable "attach_policy" {
  description = "Controls if S3 bucket should have bucket policy attached"
  type        = bool
  default     = false
}

variable "lifecycle_rule" {
  description = "List of maps containing configuration of object lifecycle management."
  type        = any
  default     = []
}

variable "logging" {
  description = "Map containing access bucket logging configuration (target_bucket, target_prefix). Use empty map {} to disable logging."
  type        = map(string)
  default     = {}
}
