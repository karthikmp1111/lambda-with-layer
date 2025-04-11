locals {
  lambda_map = { for name in var.lambda_names : name => true }
  layer_map  = { for name in var.layer_names : name => true }
}

# Lambda layer packages from S3
data "aws_s3_object" "layer_package" {
  for_each = local.layer_map
  bucket   = var.s3_bucket
  key      = "lambda-layers/${each.key}/layer.zip"
}

resource "aws_lambda_layer_version" "layers" {
  for_each = local.layer_map

  layer_name          = each.key
  compatible_runtimes = ["python3.8"]
  s3_bucket           = var.s3_bucket
  s3_key              = "lambda-layers/${each.key}/layer.zip"
  source_code_hash    = data.aws_s3_object.layer_package[each.key].etag
}

# Lambda code from S3
data "aws_s3_object" "lambda_package" {
  for_each = local.lambda_map
  bucket   = var.s3_bucket
  key      = "lambda-packages/${each.key}/package.zip"
}

resource "aws_lambda_function" "lambda" {
  for_each = local.lambda_map

  function_name = each.key
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.8"
  s3_bucket     = var.s3_bucket
  s3_key        = "lambda-packages/${each.key}/package.zip"
  source_code_hash = data.aws_s3_object.lambda_package[each.key].etag
  publish = true

  # Attach relevant layers
  layers = [
    for layer in var.lambda_layer_map[each.key] :
    aws_lambda_layer_version.layers[layer].arn
  ]

  environment {
    variables = {
      ENV           = "dev"
      NEW_VARIABLE  = "bg_lambda_test"
    }
  }

  lifecycle {
    ignore_changes = [environment, publish]
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "bg_lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })

  lifecycle {
    ignore_changes = [name]
  }
}

########Test File###########
# resource "aws_s3_bucket_object" "test_file" {
#   bucket = "bg-kar-terraform-state"
#   key    = "karthik-file.txt"
#   content = "This is a test file for Terraform configuration"
# }
