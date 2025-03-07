data "sops_file" "secrets" {
  source_file = "${path.root}/../secrets.${var.stage}.yaml"
}

resource "aws_ssm_parameter" "some-secret" {
  name  = "${local.service}-some-secret"
  type  = "SecureString"
  value = data.sops_file.secrets.data["foo"]
}

