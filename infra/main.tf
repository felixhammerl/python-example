locals {
  service = "example"
  region  = "us-east-1"
}

provider "aws" {
  region = local.region
}

resource "aws_s3_bucket" "lambda" {
  bucket_prefix = "${local.service}-deployment"
}

data "aws_iam_policy_document" "example" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["*"]
  }
}

module "example" {
  source          = "./lambda"
  bucket_name     = aws_s3_bucket.lambda.id
  function_name   = local.service
  zip_path        = "${path.root}/../build/lambda.zip"
  handler         = "example/handler/example.do_stuff"
  iam_policy_json = data.aws_iam_policy_document.example.json
  env = {
    STAGE = var.stage
  }
}

module "sfn" {
  source       = "./sfn"
  module_name  = local.service
  step_example = module.example.arn
}
