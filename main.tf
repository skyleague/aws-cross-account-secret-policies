data "aws_caller_identity" "current" {}
data "aws_organizations_organization" "current" {
  count = var.enable_strict_org_check ? 1 : 0
}

# Reference: https://aws.amazon.com/blogs/security/how-to-use-resource-based-policies-aws-secrets-manager-console-to-securely-access-secrets-aws-accounts/
data "aws_iam_policy_document" "cross_account_secret_read" {
  dynamic "statement" {
    for_each = var.enable_strict_org_check ? [true] : []
    content {
      # https://dev.to/aws-builders/power-of-aws-organization-id-in-controlling-access-to-aws-resources-jc4
      sid       = "DenyOutsideOrg"
      effect    = "Deny"
      resources = ["*"]
      actions   = ["*"]
      principals {
        type        = "*"
        identifiers = ["*"]
      }
      condition {
        test     = "StringNotEquals"
        variable = "aws:PrincipalOrgID"
        values   = [data.aws_organizations_organization.current[0].id]
      }
    }
  }
  dynamic "statement" {
    for_each = {
      StringEquals = "AWSCURRENT"
      Null         = true
    }
    content {
      condition {
        test     = statement.key
        variable = "secretsmanager:VersionStage"
        values   = [statement.value]
      }
      effect = "Allow"
      # Since this will be a resource-policy, we need to put "*" here
      resources = ["*"]
      actions   = ["secretsmanager:GetSecretValue"]
      dynamic "principals" {
        for_each = var.principals
        content {
          type        = principals.key
          identifiers = principals.value
        }
      }
    }
  }
}
data "aws_iam_policy_document" "cross_account_kms_decrypt" {
  # Enable IAM policies
  statement {
    sid       = "EnableIAM"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
  dynamic "statement" {
    for_each = var.enable_strict_org_check ? [true] : []
    content {
      # https://dev.to/aws-builders/power-of-aws-organization-id-in-controlling-access-to-aws-resources-jc4
      sid       = "DenyOutsideOrg"
      effect    = "Deny"
      resources = ["*"]
      actions   = ["*"]
      principals {
        type        = "*"
        identifiers = ["*"]
      }
      condition {
        test     = "StringNotEquals"
        variable = "aws:PrincipalOrgID"
        values   = [data.aws_organizations_organization.current[0].id]
      }
    }
  }

  statement {
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = ["*"]
    dynamic "principals" {
      for_each = var.principals
      content {
        type        = principals.key
        identifiers = principals.value
      }
    }
  }
}
