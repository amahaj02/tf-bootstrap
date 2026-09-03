variable "iam_roles" {
  description = "IAM roles and their individual trust and permissions policies"

  type = map(object({
    trusted_services         = set(string)
    managed_policy_arns      = set(string)
    permissions_boundary_arn = string
    tags                     = map(string)
  }))
}

variable "aws_region" {
  description = "AWS region used by the AWS provider"
  type        = string
  default     = "ca-central-1"
}
