# output "lambda_arns" {
#   value = { for k, v in aws_lambda_function.lambda : k => v.arn }
# }

# output "lambda_versions" {
#   value = { for k, v in aws_lambda_function.lambda : k => v.version }
# }

output "lambda_arns" {
  value = {
    lambda1 = aws_lambda_function.lambda1.arn
    lambda2 = aws_lambda_function.lambda2.arn
    lambda3 = aws_lambda_function.lambda3.arn
  }
}

output "lambda_versions" {
  value = {
    lambda1 = aws_lambda_function.lambda1.version
    lambda2 = aws_lambda_function.lambda2.version
    lambda3 = aws_lambda_function.lambda3.version
  }
}
