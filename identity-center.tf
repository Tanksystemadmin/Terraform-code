#--------------------#
# Retrieve account id 
#--------------------#
data "aws_caller_identity" "current" {}

locals {
  # Group definitions
  sso_groups = {
    Admin = {
      group_name        = "Admin"
      group_description = "Admin IAM Identity Center Group"
    },
    Developers = {
      group_name        = "Developers"
      group_description = "Dev IAM Identity Center Group"
    }
  }

  # User definitions
  sso_users = {
    syates = {
      group_membership = [local.sso_groups.Admin.group_name]
      user_name        = "syates"
      given_name       = "Sheridan"
      family_name      = "Yates"
      email            = "Sheridan@iscuw.org"
    },
  }

  # Permission sets definitions
  permission_sets = {
    AdministratorAccess = {
      description          = "Provides AWS full access permissions."
      session_duration     = "PT4H"
      aws_managed_policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]
      tags                 = { ManagedBy = "Terraform" }
    },
    ViewOnlyAccess = {
      description          = "Provides AWS view only permissions."
      session_duration     = "PT3H"
      aws_managed_policies = ["arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"]
      tags                 = { ManagedBy = "Terraform" }
    }
  }

  # Account assignments
  account_assignments = {
    Admin = {
      principal_name  = local.sso_groups.Admin.group_name
      principal_type  = "GROUP"
      principal_idp   = "INTERNAL"
      permission_sets = ["AdministratorAccess"]
      account_ids     = [data.aws_caller_identity.current.account_id]
    },
    Developers = {
      principal_name  = local.sso_groups.Developers.group_name
      principal_type  = "GROUP"
      principal_idp   = "INTERNAL"
      permission_sets = ["ViewOnlyAccess"]
      account_ids     = [data.aws_caller_identity.current.account_id]
    }
  }
}

module "aws-iam-identity-center" {
  source = "aws-ia/iam-identity-center/aws"

  # Use local variables for groups, users, permission sets, and account assignments
  sso_groups          = local.sso_groups
  sso_users           = local.sso_users
  permission_sets     = local.permission_sets
  account_assignments = local.account_assignments
}
