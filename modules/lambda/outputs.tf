output "lambda_function_arn" {
  value = module.function.lambda_function_arn
  description = "ARN of Lambda Function"
}

output "lambda_role_arn" {
  value = module.function.lambda_role_arn
  description = "ARN of Lambda execution role"
}
