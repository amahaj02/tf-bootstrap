data "aws_iam_policy_document" "role_trust" {
  for_each = var.iam_roles

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = each.value.trusted_services
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "this" {
  for_each = var.iam_roles

  name = each.key
  path = "/projects/"

  assume_role_policy   = data.aws_iam_policy_document.role_trust[each.key].json
  permissions_boundary = each.value.permissions_boundary_arn
  tags                 = each.value.tags
}

locals {
  managed_policy_attachments = {
    for attachment in flatten([
      for role_name, role in var.iam_roles : [
        for policy_arn in role.managed_policy_arns : {
          role_name  = role_name
          policy_arn = policy_arn
        }
      ]
    ]) : "${attachment.role_name}:${attachment.policy_arn}" => attachment
  }
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each = local.managed_policy_attachments

  role       = aws_iam_role.this[each.value.role_name].name
  policy_arn = each.value.policy_arn
}

data "aws_iam_policy_document" "inline" {
  for_each = {
    for role_name, role in var.iam_roles : role_name => role
    if length(role.inline_policy_statements) > 0
  }

  dynamic "statement" {
    for_each = each.value.inline_policy_statements

    content {
      sid       = statement.value.sid
      effect    = statement.value.effect
      actions   = statement.value.actions
      resources = statement.value.resources

      dynamic "condition" {
        for_each = statement.value.conditions

        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}

resource "aws_iam_role_policy" "inline" {
  for_each = data.aws_iam_policy_document.inline

  name   = "${each.key}-inline"
  role   = aws_iam_role.this[each.key].name
  policy = each.value.json
}
