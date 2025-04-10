locals {
  # Define the S3 paths for the Lambda function packages
  lambda_files = {
    for name in var.lambda_names : name => "s3://bg-kar-terraform-state/lambda-packages/${name}/package.zip"
  }

  # Define the Lambda layers for each function
  lambda_layers = {
    "lambda1" = ["layer1", "layer2"]
    "lambda2" = ["layer2", "layer3"]
    "lambda3" = ["layer1", "layer3"]
  }
}

# Fetch the Lambda function package from S3
data "aws_s3_object" "lambda_package" {
  for_each = local.lambda_files
  bucket   = "bg-kar-terraform-state"
  key      = "lambda-packages/${each.key}/package.zip"
}

# Fetch the Lambda layer packages from S3
data "aws_s3_object" "lambda_layer" {
  for_each = toset(flatten([for lambda, layers in local.lambda_layers : [for layer in layers : "s3://bg-kar-terraform-state/lambda-layers/${layer}/package.zip"]]))
  bucket   = "bg-kar-terraform-state"
  key      = each.value
}

# Create Lambda layers from the defined layer names
resource "aws_lambda_layer_version" "lambda_layer" {
  for_each = toset(flatten([for lambda, layers in local.lambda_layers : layers]))

  layer_name = each.value
  s3_bucket  = "bg-kar-terraform-state"
  s3_key     = "lambda-layers/${each.value}/package.zip"
}

# Create Lambda functions and attach the required layers
resource "aws_lambda_function" "lambda" {
  for_each = local.lambda_files

  function_name = each.key
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.8"

  s3_bucket = "bg-kar-terraform-state"
  s3_key    = "lambda-packages/${each.key}/package.zip"

  source_code_hash = data.aws_s3_object.lambda_package[each.key].etag

  # Attach layers based on the function's layers
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

# Create the IAM role for Lambda execution
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
