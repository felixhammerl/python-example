resource "aws_s3_object" "file_upload" {
  bucket = var.bucket_name
  key    = var.function_name
  source = var.zip_path
  etag   = filemd5(var.zip_path)
}

resource "aws_lambda_function" "this" {
  function_name    = var.function_name
  handler          = var.handler
  runtime          = "python3.12"
  s3_bucket        = var.bucket_name
  s3_key           = aws_s3_object.file_upload.id
  role             = aws_iam_role.lambda-exec-role.arn
  timeout          = var.timeout
  memory_size      = var.memory
  publish          = true
  source_code_hash = filebase64sha256(var.zip_path)
  environment {
    variables = var.env
  }
}
