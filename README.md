# SkyLeague `aws-cross-account-secret-policies` - all the policies you need for secure cross-account secret access

[![tfsec](https://github.com/skyleague/aws-cross-account-secret-policies/actions/workflows/tfsec.yml/badge.svg?branch=main)](https://github.com/skyleague/aws-cross-account-secret-policies/actions/workflows/tfsec.yml)

This module simplifies the setup of cross-account secrets in AWS SecretsManager using Terraform. It is a data-only module (no resources created), with two outputs: a `kms_policy` and a `secretsmanager_policy`. Both are intended to be used as resource-policy on the respective resources. As a best practice, the `principals` should be specific role(s) only, not entire accounts. This module does not create the `aws_secretsmanager_secret` and `aws_kms_key`, those can be fully configured outside of this module.

## Usage

```terraform
module "cross_account_secret_policies" {
  source = "git@github.com:skyleague/aws-cross-account-secret-policies.git?ref=v1.0.0

  principals = {
    # Replace 123456 with a (dynamic) account ID, and the `example-role` with your actual role
    AWS = "arn:aws:iam::123456:role/example-role"
  }
}

resource "aws_kms_key" "cross_account_secrets_kms" {
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  description              = "Key used for provisioning secrets"
  deletion_window_in_days  = 7
  enable_key_rotation      = true
  policy                   = module.cross_account_secret_policies.kms_policy
}
resource "aws_secretsmanager_secret" "my_awesome_secret" {
  name       = "/my/awesome/secret"
  kms_key_id = aws_kms_key.cross_account_secrets_kms.key_id
  policy     = module.cross_account_secret_policies.secretsmanager_policy
}
```

Using the above snippet, you can create a placeholder secret in a central account. The placeholder secret can then be manually given a value in the AWS Console or any means of your preference. The secret can be referenced from application accounts to provision secrets, even on accounts where write permissions are restricted to CICD-only.

## Options

For a complete reference of all variables, have a look at the descriptions in [`variables.tf`](./variables.tf).

## Outputs

The module outputs the `lambda`, `log_group` and `role` as objects, providing the flexibility to extend the Lambda Function with additional functionality, and without limiting the set of exposed outputs.

## Support

SkyLeague provides Enterprise Support on this open-source library package at clients across industries. Please get in touch via [`https://skyleague.io`](https://skyleague.io).

If you are not under Enterprise Support, feel free to raise an issue and we'll take a look at it on a best-effort basis!

## License & Copyright

This library is licensed under the MIT License (see [LICENSE.md](./LICENSE.md) for details).

If you using this SDK without Enterprise Support, please note this (partial) MIT license clause:

> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND

Copyright (c) 2022, SkyLeague Technologies B.V..
'SkyLeague' and the astronaut logo are trademarks of SkyLeague Technologies, registered at Chamber of Commerce in The Netherlands under number 86650564.

All product names, logos, brands, trademarks and registered trademarks are property of their respective owners. All company, product and service names used in this website are for identification purposes only. Use of these names, trademarks and brands does not imply endorsement.
