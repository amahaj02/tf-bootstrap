
aws_region               = "ca-central-1"
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
}
