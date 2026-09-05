# tf-bootstrap

Terraform configuration for managing project IAM roles in AWS account
`344138923336`. Roles are created under `/projects/`, stored in an S3-backed
Terraform state, and deployed from GitHub Actions through OIDC.

## Architecture

```text
GitHub Actions
      ↓ OIDC token
TerraformBootstrapRole
      ↓ temporary AWS credentials
Terraform S3 backend + AWS provider
      ↓
/projects/ IAM roles and managed-policy attachments
```

The workflow creates a binary Terraform plan, stores it as a one-day artifact,
then applies that exact plan in a dependent job.

## Repository layout

```text
.
├── .github/workflows/terraform_deploy.yaml  # GitHub OIDC plan-and-apply workflow
└── terraform/
    ├── backend.tf                            # S3 state backend
    ├── providers.tf                          # AWS provider
    ├── variables.tf                          # IAM role schema
    ├── test_role.tf                          # IAM role resources and policy attachments
    └── env/dev.tfvars                        # Development role definitions
```

## Manual AWS bootstrap

These resources existed before Terraform began managing project roles.

### Terraform state bucket

```text
Bucket: terraform-state-344138923336-ca-central-1-an
Region: ca-central-1
Key:    tf-bootstrap/terraform.tfstate
```

The bucket is private, encrypted, and versioned. Terraform uses S3 lockfiles
through `use_lockfile = true`.

### Permissions boundary

Project roles use this customer-managed boundary:

```text
arn:aws:iam::344138923336:policy/ProjectRoleBoundary
```

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowNonPrivilegeManagementActions",
      "Effect": "Allow",
      "NotAction": ["iam:*", "sts:AssumeRole"],
      "Resource": "*"
    }
  ]
}
```

### GitHub OIDC provider

```text
Provider URL: https://token.actions.githubusercontent.com
Audience:     sts.amazonaws.com
```

### Terraform bootstrap role

GitHub Actions assumes `TerraformBootstrapRole`. Its trust policy is scoped to
this repository's `main` environment. Its permissions cover:

- S3 access to the `tf-bootstrap/terraform.tfstate` state object and lockfile
- IAM role creation and management under `/projects/`
- Attachment of the configured AWS-managed policies
- Use of `ProjectRoleBoundary` as a role permissions boundary

The bootstrap role does not manage itself, the permissions-boundary policy, or
the GitHub OIDC provider.

## Role model

`terraform/env/dev.tfvars` defines an `iam_roles` map. Each map key is the IAM
role name and each entry defines its trust relationship, boundary, tags,
AWS-managed policy attachments, and optional inline policy statements.

```hcl
iam_roles = {
  ExampleLambdaRole = {
    trusted_services = ["lambda.amazonaws.com"]
    managed_policy_arns = [
      "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    ]
    permissions_boundary_arn = "arn:aws:iam::344138923336:policy/ProjectRoleBoundary"
    tags = {
      ManagedBy = "Terraform"
      Environment = "dev"
    }
  }
}
```

Use `inline_policy_statements` for permissions unique to one role. Each
statement defines its actions and resources directly on that role; no separate
policy attachment is created. Reusable policies can instead be created outside
this configuration and referenced through `managed_policy_arns`.

```hcl
inline_policy_statements = [
  {
    sid       = "AccessAuthTable"
    actions   = ["dynamodb:GetItem", "dynamodb:PutItem"]
    resources = ["arn:aws:dynamodb:ca-central-1:344138923336:table/dev-workspace-auth"]
  }
]
```

## GitHub Actions

The `Terraform Plan and Apply` workflow runs for relevant pushes to `main` and
manual dispatches. It uses the `main` GitHub Environment and reads this
environment variable:

```text
OIDC_ROLE_ARN = arn:aws:iam::344138923336:role/TerraformBootstrapRole
```

The workflow verifies the assumed AWS identity, initializes the S3 backend,
generates `tfplan`, uploads it as an artifact, and applies the downloaded plan
in the second job.

The apply job references the `main` GitHub Environment. To require manual
approval before it runs, configure a required reviewer in `Settings >
Environments > main`. After planning succeeds, approve the waiting deployment
from the Actions run with `Review deployments` and `Approve and deploy`.
