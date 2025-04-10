# Create IAM Role for Lambda execution
resource "aws_iam_role" "lambda_role" {
  name               = "bg_lambda_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Create Lambda Layer 1 from S3
resource "aws_lambda_layer_version" "lambda_layer1" {
  layer_name  = "layer1"
  s3_bucket   = "bg-kar-terraform-state"
  s3_key      = "lambda-layers/layer1/package.zip"
  compatible_runtimes = ["python3.8"]
}

# Create Lambda Layer 2 from S3
resource "aws_lambda_layer_version" "lambda_layer2" {
  layer_name  = "layer2"
  s3_bucket   = "bg-kar-terraform-state"
  s3_key      = "lambda-layers/layer2/package.zip"
  compatible_runtimes = ["python3.8"]
}

# Create Lambda Layer 3 from S3
resource "aws_lambda_layer_version" "lambda_layer3" {
  layer_name  = "layer3"
  s3_bucket   = "bg-kar-terraform-state"
  s3_key      = "lambda-layers/layer3/package.zip"
  compatible_runtimes = ["python3.8"]
}

# Create Lambda Function 1
resource "aws_lambda_function" "lambda1" {
  function_name = "lambda1"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "python3.8"
  handler       = "index.lambda_handler"
  memory_size   = 128
  timeout       = 3
  s3_bucket     = "bg-kar-terraform-state"
  s3_key        = "lambda-packages/lambda1/package.zip"

  environment {
    variables = {
      ENV = "dev"
    }
  }

  layers = [
    aws_lambda_layer_version.lambda_layer1.arn
  ]
}

# Create Lambda Function 2
resource "aws_lambda_function" "lambda2" {
  function_name = "lambda2"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "python3.8"
  handler       = "index.lambda_handler"
  memory_size   = 128
  timeout       = 3
  s3_bucket     = "bg-kar-terraform-state"
  s3_key        = "lambda-packages/lambda2/package.zip"

  environment {
    variables = {
      ENV = "dev"
    }
  }

  layers = [
    aws_lambda_layer_version.lambda_layer2.arn
  ]
}

# Create Lambda Function 3
resource "aws_lambda_function" "lambda3" {
  function_name = "lambda3"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "python3.8"
  handler       = "index.lambda_handler"
  memory_size   = 128
  timeout       = 3
  s3_bucket     = "bg-kar-terraform-state"
  s3_key        = "lambda-packages/lambda3/package.zip"

  environment {
    variables = {
      ENV = "dev"
    }
  }

  layers = [
    aws_lambda_layer_version.lambda_layer3.arn
  ]
}

# Output the ARNs of Lambda Functions
output "lambda_arns" {
  value = {
    lambda1 = aws_lambda_function.lambda1.arn
    lambda2 = aws_lambda_function.lambda2.arn
    lambda3 = aws_lambda_function.lambda3.arn
  }
}

# Output the versions of Lambda Functions
output "lambda_versions" {
  value = {
    lambda1 = aws_lambda_function.lambda1.version
    lambda2 = aws_lambda_function.lambda2.version
    lambda3 = aws_lambda_function.lambda3.version
  }
}


########Test File###########
# resource "aws_s3_bucket_object" "test_file" {
#   bucket = "bg-kar-terraform-state"
#   key    = "karthik-file.txt"
#   content = "This is a test file for Terraform configuration"
# }
