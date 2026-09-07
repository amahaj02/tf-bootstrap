
aws_region = "ca-central-1"
iam_roles = {
  TestProjectRole = {
    trusted_services = ["lambda.amazonaws.com"]
    managed_policy_arns = [
      "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    ]
    permissions_boundary_arn = "arn:aws:iam::344138923336:policy/ProjectRoleBoundary"
    tags = {
      ManagedBy = "Terraform"
      Project   = "tf-bootstrap-test"
      Service   = "lambda"
    }
  }

  TestProjectRoleTwo = {
    trusted_services = ["ecs-tasks.amazonaws.com"]
    managed_policy_arns = [
      "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
    ]
    permissions_boundary_arn = "arn:aws:iam::344138923336:policy/ProjectRoleBoundary"
    tags = {
      ManagedBy = "Terraform"
      Project   = "tf-bootstrap-test"
      Service   = "ecs"
    }
  }
  DevWorkspaceMCPProjectRole = {
    trusted_services    = ["lambda.amazonaws.com"]
    managed_policy_arns = []
    inline_policy_statements = [
      {
        sid = "UseAuthTable"
        actions = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        resources = [
          "arn:aws:dynamodb:ca-central-1:344138923336:table/dev-workspace-auth"
        ]
      },
      {
        sid = "WriteLogsToCW"
        actions = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        resources = [
          "arn:aws:logs:ca-central-1:344138923336:log-group:/aws/lambda/dev-workspace-mcp:*"
        ]
      }
    ]
    permissions_boundary_arn = "arn:aws:iam::344138923336:policy/ProjectRoleBoundary"
    tags = {
      ManagedBy = "Terraform"
      Project   = "dev-workspace-mcp-project"
    }
  },
  DevWorkspaceMCPProjectTFDeploymentRole = {
    github_oidc = {
      provider_arn = "arn:aws:iam::344138923336:oidc-provider/token.actions.githubusercontent.com"
      subjects = [
        "repo:amahaj02@122768341/dev-workspace-mcp@1358724843:environment:main",
        "repo:amahaj02@122768341/dev-workspace-mcp@1358724843:ref:refs/heads/main",
      ]
    }

    managed_policy_arns = []

    inline_policy_statements = [
      {
        sid = "ManageProjectTerraformState"

        actions = [
          "s3:GetObject",
          "s3:PutObject"
        ]

        resources = [
          "arn:aws:s3:::terraform-state-344138923336-ca-central-1-an/dev-workspace-mcp/terraform.tfstate",
          "arn:aws:s3:::terraform-state-344138923336-ca-central-1-an/dev-workspace-mcp/terraform.tfstate.tflock",
        ]
      },
      {
        sid = "ListProjectTerraformState"

        actions = [
          "s3:ListBucket"
        ]

        resources = [
          "arn:aws:s3:::terraform-state-344138923336-ca-central-1-an"
        ]

        conditions = [
          {
            test     = "StringLike"
            variable = "s3:prefix"
            values = [
              "dev-workspace-mcp/terraform.tfstate",
              "dev-workspace-mcp/terraform.tfstate.tflock",
            ]
          }
        ]
      },
      {
        sid = "DeleteProjectTerraformLock"

        actions = [
          "s3:DeleteObject",
        ]

        resources = [
          "arn:aws:s3:::terraform-state-344138923336-ca-central-1-an/dev-workspace-mcp/terraform.tfstate.tflock",
        ]
      },

      {
        sid = "ManageAuthTable"
        actions = [
          "dynamodb:CreateTable",
          "dynamodb:DeleteTable",
          "dynamodb:DescribeTable",
          "dynamodb:DescribeTimeToLive",
          "dynamodb:ListTagsOfResource",
          "dynamodb:TagResource",
          "dynamodb:UntagResource",
          "dynamodb:UpdateTable",
          "dynamodb:UpdateTimeToLive",
          "dynamodb:DescribeContinuousBackups"
        ]
        resources = [
          "arn:aws:dynamodb:ca-central-1:344138923336:table/dev-workspace-auth"
        ]
      },
      {
        sid = "ManageAppLambda"
        actions = [
          "lambda:AddPermission",
          "lambda:CreateFunction",
          "lambda:CreateFunctionUrlConfig",
          "lambda:DeleteFunction",
          "lambda:DeleteFunctionUrlConfig",
          "lambda:GetFunction",
          "lambda:GetFunctionUrlConfig",
          "lambda:GetPolicy",
          "lambda:ListTags",
          "lambda:RemovePermission",
          "lambda:TagResource",
          "lambda:UntagResource",
          "lambda:UpdateFunctionCode",
          "lambda:UpdateFunctionConfiguration",
          "lambda:UpdateFunctionUrlConfig",
        ]
        resources = [
          "arn:aws:lambda:ca-central-1:344138923336:function:dev-workspace-mcp"
        ]
      },
      {
        sid     = "PassAppExecutionRole"
        actions = ["iam:PassRole"]
        resources = [
          "arn:aws:iam::344138923336:role/projects/DevWorkspaceMCPProjectRole"
        ]
        conditions = [
          {
            test     = "StringEquals"
            variable = "iam:PassedToService"
            values   = ["lambda.amazonaws.com"]
          }
        ]
      },
      {
        sid = "CreateAndDiscoverAppLogGroup"
        actions = [
          "logs:CreateLogGroup",
          "logs:DescribeLogGroups",
        ]
        resources = ["*"]
      },
      {
        sid = "ManageAppLogGroup"
        actions = [
          "logs:DeleteLogGroup",
          "logs:ListTagsForResource",
          "logs:PutRetentionPolicy",
          "logs:TagResource",
          "logs:UntagResource",
        ]
        resources = [
          "arn:aws:logs:ca-central-1:344138923336:log-group:/aws/lambda/dev-workspace-mcp:*"
        ]
      },
    ]
    permissions_boundary_arn = "arn:aws:iam::344138923336:policy/ProjectRoleBoundary"

    tags = {
      ManagedBy = "Terraform"
      Project   = "dev-workspace-mcp-project"
    }

  }
}
