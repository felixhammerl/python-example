resource "aws_sfn_state_machine" "sfn" {
  name     = var.module_name
  role_arn = aws_iam_role.sfn.arn
  definition = jsonencode({
    "StartAt" : "Example",
    "States" : {
      "Example" : {
        "Type" : "Task",
        "Resource" : var.step_example,
        "End" : true
      },
    }
  })
}
