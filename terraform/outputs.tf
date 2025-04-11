# output "lambda_arns" {
#   value = { for k, v in aws_lambda_function.lambda : k => v.arn }
# }

# output "lambda_versions" {
#   value = { for k, v in aws_lambda_function.lambda : k => v.version }
# }

output "lambda_arns" {
  value = { for k, v in aws_lambda_function.lambda : k => v.arn }
}

output "lambda_versions" {
  value = { for k, v in aws_lambda_function.lambda : k => v.version }
}

output "layer_versions" {
  value = { for k, v in aws_lambda_layer_version.layers : k => v.arn }
}
