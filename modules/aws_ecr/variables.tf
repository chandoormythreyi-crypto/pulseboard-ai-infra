variable "env" {
  description = "Environment name"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.env)
    error_message = "The env value must be one of: dev, staging, prod."
  }
}


variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
}

variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository"
  type        = bool
  default     = false
}

variable "max_image_count" {
  description = "Maximum number of images to keep in the repository"
  type        = number
  default     = 100
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
} 
