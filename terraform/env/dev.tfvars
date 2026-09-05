
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
        sid = "CreateAndConfigureAuthTable"
        actions = [
          "dynamodb:CreateTable",
          "dynamodb:DescribeTable",
          "dynamodb:TagResource",
          "dynamodb:UpdateTimeToLive",
        ]
        resources = [
          "arn:aws:dynamodb:ca-central-1:344138923336:table/dev-workspace-auth"
        ]
      },
      {
        sid = "UseAuthTable"
        actions = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ]
        resources = [
          "arn:aws:dynamodb:ca-central-1:344138923336:table/dev-workspace-auth"
        ]
      }
    ]
    permissions_boundary_arn = "arn:aws:iam::344138923336:policy/ProjectRoleBoundary"
    tags = {
      ManagedBy = "Terraform"
      Project   = "dev-workspace-mcp-project"
    }
  }
}
