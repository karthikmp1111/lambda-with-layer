variable "aws_region" {
  default = "us-west-1"
}

variable "s3_bucket" {
  default = "bg-kar-terraform-state"
}

variable "lambda_names" {
  type    = list(string)
  default = ["lambda1", "lambda2", "lambda3"]
}

variable "layer_names" {
  type    = list(string)
  default = ["layer1", "layer2", "layer3"]
}

variable "lambda_layer_map" {
  type = map(list(string))
  default = {
    lambda1 = ["layer1", "layer2"]
    lambda2 = ["layer2", "layer3"]
    lambda3 = ["layer1", "layer3"]
  }
}
