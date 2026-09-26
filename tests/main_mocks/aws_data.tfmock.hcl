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
# lambda module
##############################################
override_data {
  target = module.lambda.module.function.data.aws_iam_policy_document.assume_role
    values = {
      json = <<EOF
            {
              "Version": "2012-10-17",
              "Statement": {
                "Effect": "Allow",
                "Principal": {
                  "Service": "lambda.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
              }
            }
            EOF
  }
}
override_data {
  target = module.lambda.module.function.data.aws_iam_policy_document.additional_inline
    values = {
      json = <<EOF
            {
              "Version": "2012-10-17",
              "Statement": {
                "Effect": "Allow",
                "Action": [
                  "ec2:*"
                ],
                "Resource": "*"
              }
            }
            EOF
  }
}