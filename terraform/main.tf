locals {
  lambda_files = {
    for name in var.lambda_names : name => "s3://bg-kar-terraform-state/lambda-packages/${name}/package.zip"
  }
  lambda_layers = {
    "lambda1" = ["layer1", "layer2"]
    "lambda2" = ["layer2", "layer3"]
    "lambda3" = ["layer1", "layer3"]
  }
}

data "aws_s3_object" "lambda_package" {
  for_each = local.lambda_files
  bucket   = "bg-kar-terraform-state"
  key      = "lambda-packages/${each.key}/package.zip"
}

data "aws_s3_object" "lambda_layer" {
  for_each = flatten([for lambda, layers in local.lambda_layers : [for layer in layers : "s3://bg-kar-terraform-state/lambda-layers/${layer}/package.zip"]])
  bucket   = "bg-kar-terraform-state"
  key      = each.value
}

resource "aws_lambda_layer_version" "lambda_layer" {
  for_each = toset(flatten([for lambda, layers in local.lambda_layers : layers]))

  layer_name = each.value
  s3_bucket  = "bg-kar-terraform-state"
  s3_key     = "lambda-layers/${each.value}/package.zip"
}

resource "aws_lambda_function" "lambda" {
  for_each = local.lambda_files

  function_name = each.key
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.8"

  s3_bucket = "bg-kar-terraform-state"
  s3_key    = "lambda-packages/${each.key}/package.zip"

  source_code_hash = data.aws_s3_object.lambda_package[each.key].etag

  layers = flatten([for layer in local.lambda_layers[each.key] : aws_lambda_layer_version.lambda_layer[layer].arn])

  publish = true

  environment {
    variables = {
      ENV = "dev"
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
