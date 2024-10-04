resource "aws_iam_role" "lambda-exec-role" {
  name               = "${var.function_name}-lambda-execution"
  assume_role_policy = data.aws_iam_policy_document.lambda-exec-role.json
}

data "aws_iam_policy_document" "lambda-exec-role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "edgelambda.amazonaws.com",
        "lambda.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda-exec-role.name
  policy_arn = aws_iam_policy.lambda-iam-policy.arn
}

resource "aws_iam_policy" "lambda-iam-policy" {
  name   = "${var.function_name}-lambda-execution"
  policy = var.iam_policy_json
}
