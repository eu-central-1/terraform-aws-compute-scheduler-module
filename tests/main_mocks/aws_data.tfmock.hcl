##############################################
# general aws provider data
##############################################
mock_data "aws_partition" {
  defaults = {
    partition = "aws"
  }
}
mock_data "aws_caller_identity" {
  defaults = {
    account_id = "123456789012"
  }
}
mock_data "aws_region" {
  defaults = {
    id = "eu-central-1"
  }
}

##############################################
# root module
##############################################
# override_data {
#   target = data.aws_iam_policy_document.enhanced_monitoring
#   values = {
#   json = <<EOF
#     {
#       "Version": "2012-10-17",
#       "Statement": {
#         "Effect": "Allow",
#         "Action": [
#           "logs:*"
#         ],
#         "Resource": "*"
#       }
#     }
#     EOF
#   }
# }
