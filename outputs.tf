output "kms_policy" {
  value = data.aws_iam_policy_document.cross_account_kms_decrypt.json
}

output "secretsmanager_policy" {
  value = data.aws_iam_policy_document.cross_account_secret_read.json
}
