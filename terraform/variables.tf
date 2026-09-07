variable "iam_roles" {
  description = "IAM roles and their individual trust and permissions policies"

  type = map(object({
    trusted_services = optional(set(string), [])
    github_oidc = optional(object({
      provider_arn = string
    subjects = set(string) }), null)
    managed_policy_arns = set(string)
    inline_policy_statements = optional(list(object({
      sid       = optional(string)
      effect    = optional(string, "Allow")
      actions   = set(string)
      resources = set(string)
      conditions = optional(list(object({
        test     = string
        variable = string
        values   = set(string)
      })), [])
    })), [])
    permissions_boundary_arn = string
    tags                     = map(string)
  }))
}

variable "aws_region" {
  description = "AWS region used by the AWS provider"
  type        = string
  default     = "ca-central-1"
}
