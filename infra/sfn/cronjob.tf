module "eventbridge" {
  source = "terraform-aws-modules/eventbridge/aws"

  create_bus = false

  rules = {
    crons = {
      description         = "Run state machine everyday 4:00 UTC"
      schedule_expression = "cron(0 4 * * ? *)"
    }
  }

  targets = {
    crons = [
      {
        name            = var.module_name
        arn             = aws_sfn_state_machine.sfn.arn
        attach_role_arn = true
      }
    ]
  }

  sfn_target_arns   = [aws_sfn_state_machine.sfn.arn]
  attach_sfn_policy = true
}
