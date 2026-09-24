# AWS ECR Module

This module creates a secure Amazon Elastic Container Registry (ECR) repository with automated lifecycle management, image scanning capabilities, and integrated IAM policies for AWS App Runner. It provides a complete container image storage solution with security scanning, retention policies, and seamless integration with container orchestration services.

## Resources Created

- **ECR Repository**: Private container image repository with configurable image tag mutability
- **Lifecycle Policy**: Automated image retention management to control repository size and costs
- **IAM Policy**: Specialized policy for AWS App Runner ECR access with least-privilege permissions
- **IAM Role**: Service role for App Runner services to pull container images
- **IAM Role Policy Attachment**: Links the ECR access policy to the App Runner service role

## Architecture

The module implements a secure container registry architecture:
- **Storage Layer**: Private ECR repository with encrypted image storage
- **Access Control**: IAM-based authentication and authorization for image operations
- **Lifecycle Management**: Automated cleanup policies to manage storage costs
- **Integration Layer**: Pre-configured IAM roles for seamless App Runner integration

## Example for .tfvars

```hcl
env         = "prod"
region      = "eu-central-1"

repository_name      = "my-app-services"
image_tag_mutability = "MUTABLE"
scan_on_push         = true
max_image_count      = 50

common_tags = {
  Environment = "production"
  Project     = "my-application"
  Team        = "backend-team"
}
```

## Example for module

```hcl
module "ecr" {
  source = "../modules/ecr"

  env         = var.env
  common_tags = local.common_tags
  region      = var.region

  repository_name      = "my-app-services"
  image_tag_mutability = "MUTABLE"
  scan_on_push         = false
  max_image_count      = var.ecr_max_image_count
}
```